module Csible

  module CSV

    def self.get_config(config_file)
      raise "Invalid input file #{config_file}" unless File.file? config_file
      types = ["required", "optional", "generated"]
      fields = Hash.new { |hash, key| hash[key] = [] }
      ::CSV.foreach(config_file, {
          headers: true,
          header_converters: ->(header) { header.to_sym },
        }) do |row|
          data = row.to_hash
          raise "Type must be required or optional but was #{type}" unless types.include? data[:type]
          fields[:required] << data[:field] if data[:type] == "required"
          fields[:optional] << data[:field] if data[:type] == "optional"
          fields[:filename] << data[:field] if data[:filename] =~ /(^t|^true)/
      end
      raise "No required fields defined in #{config_file}" if fields[:required].empty?
      raise "Filename is undefined in #{config_file}" if fields[:filename].empty?
      fields[:filter]     = {}
      fields[:generate]   = {}
      fields[:transforms] = {}
      fields
    end

    def self.print_fields(required, optional, generated = [])
      required.map{ |r| puts "#{r} * required" }
      puts optional
      generated.map{ |r| puts "#{r} * generated" }
    end

    def self.write(filename, data, log = Logger.new(STDOUT))
      ::CSV.open(filename, 'w') do |csv|
        csv << data.first.keys
        data.each { |row| csv << row.values }
      end
    end

    module Helpers

      def check_files!
        raise "Invalid input file #{input}" unless File.file? input
        raise "Configuration not found #{config}" unless File.file? config
        raise "Invalid output directory #{output}" unless File.directory? output
      end

      # reads config as csv
      def get_map_from_csv
        ::CSV.foreach(config, {
            headers: true,
            header_converters: ->(header) { header.to_sym },
          }) do |row|
            data = row.to_hash
            yield data
        end
      end

    end

    class Processor
      include Helpers
      attr_reader :input, :output, :config, :fields, :log

      def initialize(input, output, config, fields = {}, log = Logger.new(STDOUT))
        @input  = input
        @output = output
        @config = config
        @fields = fields
        @log    = log
      end

      # TODO: load authority item types from CSV
      def authority_itemtypes(type)
        types = {
          "locations" => "LocationItem",
        }
        types[type]
      end

      # TODO: can improve this in the future
      def converters
        converters = []
        csv_nil_to_empty = -> (field) { field.nil? ? "" : field }
        csv_xml_safe     = -> (field) { field.gsub(/&/, "&amp;") }
        converters = [ csv_nil_to_empty, csv_xml_safe ]        
        converters
      end

      # TODO: load currencies from CSV
      def get_currency_code(value)
        c = {
          australiandollar: "AUD",
          danishkrone: "DKK",
          euro: "EUR",
          usdollar: "USD",
        }[value.downcase.gsub(/\s/, '').to_sym]
        return c.nil? ? "" : c
      end

      def get_short_identifier(value)
        v_str = value.gsub(/\W/, ''); # remove non-words
        v_enc = Base64.strict_encode64(v_str); # encode it
        v = v_str + v_enc.gsub(/\W/, ''); # remove non-words from result
        v
      end

      def process_fields(data, generated_values)
        # use stop gap converters
        data.each { |key, value| converters.each { |c| data[key] = c.call(data[key]) } }

        # process filters (skip if filter)
        skip = false
        fields[:filter].each do |filter, spec|
          skip    = true if spec.call(data[filter])
          break if skip
        end
        raise "SKIP FILTER #{data}" if skip

        # check required fields have value and pad optional fields to allow partial csv
        fields[:required].each { |r| raise "HELL" unless data.has_key? r.to_sym or data[r.to_sym].empty? }
        fields[:optional].each { |r| data[r.to_sym] = "" unless data.has_key? r.to_sym }

        fields[:transforms].each do |field, spec|
          data[field] = spec.call(data[field])
        end

        fields[:generate].each do |field, spec|
          source_value  = data[spec[:from]]
          derived_value = spec[:process].is_a?(Proc) ? spec[:process].call(source_value) : send(spec[:process], source_value)
          raise "Generated value should not be nil" if derived_value.nil?
          raise "Generated value is invalid for #{source_value}" if spec[:required] and derived_value.empty?
          raise "Generated value is not unique #{derived_value}" if spec[:unique] and generated_values.include? derived_value
          generated_values << derived_value
          data[field] = derived_value
        end
        data 
      end

      def run
        check_files!
        generated_values = Set.new
        ::CSV.foreach(input, {
            headers: true,
            header_converters: ->(header) { header.to_sym },
            converters: [],
          }) do |row|

          data = row.to_hash
          begin
            data = process_fields data, generated_values
            yield data
          rescue Exception => ex
            log.error ex.message
          end
        end

      end

    end

    class CollectionSpace < Processor

      def process
        run do |data|
          # set the domain for cspace urn values
          data[:domain] = fields[:domain]

          # pp data
          template = Csible.get_template config
          result   = template.result(binding).gsub(/\n+/,"\n") # binding adds variables from scope

          output_filename = fields[:filename].inject("") { |fn, field| fn += data[field.to_sym] }
          Csible.write_file("#{output}/#{output_filename}.xml", result)
        end
      end

    end

    class PastPerfect < Processor

      def convert(key, value, map)
        return map[key][:type].to_sym, { map[key][:to].to_sym => value }
      end

      def get_map
        map = {}
        get_map_from_csv do |data|
          ppfield = data[:ppfield].to_sym
          map[ppfield] = {}
          map[ppfield][:type] = data.fetch(:cspaceprocedure, data[:cspaceauthority])
          map[ppfield][:to]   = data.fetch(:cspacefield)
        end
        map
      end

      def process
        map = get_map
        mapped_data = Hash.new { |h,k| h[k] = [] }

        run do |data|
          cspace_data = Hash.new { |h,k| h[k] = {} }
          data.each do |k,v|
            t, d = convert(k, v, map)
            cspace_data[t] = cspace_data[t].merge d
          end
          cspace_data.keys.each { |type| mapped_data[type] << cspace_data[type] }
        end

        # TODO: write csv output to file for each mapped record type
        ap mapped_data
      end

    end

  end

end
