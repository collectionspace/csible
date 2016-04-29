module Csible

  module CSV

    def self.get_config(config_file, config_fields = { field_name: :field, field_type: :type })
      raise "Invalid input file #{config_file}" unless File.file? config_file
      types = ["required", "optional", "generated"]
      fields = Hash.new { |hash, key| hash[key] = [] }
      ::CSV.foreach(config_file, {
          headers: true,
          header_converters: ->(header) { header.to_sym },
        }) do |row|
          data = row.to_hash
          raise "Type must be required or optional but was #{type}" unless types.include? data[ config_fields[:field_type] ]
          fields[:required] << data[ config_fields[:field_name] ] if data[ config_fields[:field_type] ] == "required"
          fields[:optional] << data[ config_fields[:field_name] ] if data[ config_fields[:field_type] ] == "optional"
      end
      raise "No required fields defined in #{config_file}" if fields[:required].empty?
      fields[:filter]     = {}
      fields[:generate]   = {}
      fields[:merge]      = {}
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
        csv_strip        = -> (field) { field.strip }
        csv_xml_safe     = -> (field) { field.gsub(/&/, "&amp;") }
        converters = [ csv_nil_to_empty, csv_strip, csv_xml_safe ]
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
        fields[:required].each { |r| raise "MISSING REQUIRED FIELD DATA #{r}" if not data.has_key? r.to_sym or data[r.to_sym].empty? }
        fields[:optional].each { |r| data[r.to_sym] = "" unless data.has_key? r.to_sym }

        fields[:merge].each do |from, to|
          data[to] += ". #{data[from]}".gsub(/^(. )/, "").gsub("\n", ". ")
          data.delete from
        end

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
            log.error "#{ex.message} #{data}"
          end
        end

      end

    end

    class CollectionSpace < Processor

      def process(filename_field)
        run do |data|
          # set the domain for cspace urn values
          data[:domain] = fields[:domain]

          # pp data
          template = Csible.get_template config
          result   = template.result(binding).gsub(/\n+/,"\n") # binding adds variables from scope

          output_filename = data[filename_field].gsub(/\W/, '')
          Csible.write_file("#{output}/#{output_filename}.xml", result)
        end
      end

    end

    class PastPerfect < Processor

      def convert(type, key, value, map)
        return nil, nil unless map.has_key?(key) and map[key][type][:type]
        return map[key][type][:type].to_sym, { map[key][type][:to].to_sym => value }
      end

      def get_map
        map = {}
        get_map_from_csv do |data|
          ppfield = data[:ppfield].to_sym
          map[ppfield] = Hash.new { |h,k| h[k] = {} }
          map[ppfield][:procedure][:type] = data.fetch(:cspaceprocedure, nil)
          map[ppfield][:procedure][:to]   = data.fetch(:cspaceprocedurefield)

          map[ppfield][:authority][:type] = data.fetch(:cspaceauthority, nil)
          map[ppfield][:authority][:to]   = data.fetch(:cspaceauthorityfield)
          map[ppfield][:authority][:ref]  = data.fetch(:cspaceauthorityref)
        end
        map
      end


      def process_authorities(auth_data, data, map)
        hdrs = {}
        refs = Hash.new { |h,k| h[k] = {} }
        data.each do |k, v|
          ref = map.has_key?(k) ? map[k][:authority][:ref] : nil
          if ref
            ref = ref.to_sym
            t, d = convert(:authority, k, v, map)
            refs[ref] = refs[ref].merge d unless t.nil?
            data.delete k
            hdrs[ map[k][:authority][:to].to_sym ] = ''
          end
        end

        data.each do |k,v|
          t, d = convert(:authority, k, v, map)
          unless t.nil?
            d = hdrs.merge(d.merge( refs[k] ) ) # if refs.has_key? k
            if d.has_key?(:termDisplayName) and ! d[:termDisplayName].empty?
              existing_auth = auth_data[t].find { |ea| ea[:termDisplayName] == d[:termDisplayName] }
              if existing_auth
                d = d.delete_if { |k, v| v.empty? }
                existing_auth.merge d
              else
                auth_data[t] << d
              end
            end
          end
        end
      end


      def process_procedures(mapped_data, data, map)
        cspace_data = Hash.new { |h,k| h[k] = {} }
        data.each do |k,v|
          t, d = convert(:procedure, k, v, map)
          cspace_data[t] = cspace_data[t].merge d unless t.nil?
        end
        cspace_data.keys.each { |type| mapped_data[type] << cspace_data[type] }
      end

      def process
        map         = get_map
        mapped_data = Hash.new { |h,k| h[k] = [] }
        auth_data   = Hash.new { |h,k| h[k] = [] }

        run do |data|
          process_procedures mapped_data, data, map
          process_authorities auth_data, data, map
        end

        mapped_data.each { |type, data| Csible.write_csv "#{output}/#{type.to_s}.csv", data }
        auth_data.each   { |type, data| Csible.write_csv "#{output}/#{type.to_s}.csv", data }
      end

    end

  end

end
