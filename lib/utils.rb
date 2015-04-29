##### CSV helpers

CSV::Converters[:nil_to_empty] = lambda do |field|
  field ? field : ""
end

CSV::Converters[:xml_safe] = lambda do |field|
  field.gsub(/&/, "&amp;")
end

##### CS HELPERS

def authority_itemtypes(type)
  types = {
    "locations" => "LocationItem",
  }
  types[type]
end

# ansible playbook command wrapper
def command(base, method, opts = {})
  command = base + " --extra-vars='method=#{method}"
  opts.each do |arg, value|
    command = "#{command} #{arg.to_s}=#{value}" if value
  end
  command = "#{command}'"
  command
end

def get_identifiers(path, id, throttle = 1)
  identifiers = {}
  Rake::Task["cs:get:path"].invoke(path, "kw=#{id}")
  response    = Nokogiri::XML.parse(File.open("response.xml"))
  total_items = response.css("totalItems").text.to_i
  if total_items == 1
    identifiers["csid"] = response.css("csid").text
    identifiers["uri"]  = response.css("uri").text
    `sleep #{throttle}`
    Rake::Task["cs:get:path"].reenable
  else
    identifiers = nil
  end
  identifiers
end

def get_list_properties(path, properties = [], params = nil)
  list = []
  Rake::Task["cs:get:path"].invoke(path, params)
  response = Nokogiri::XML.parse(File.open("response.xml"))
  response.css("list-item").each do |list_item|
    i = {}
    properties.each do |property|
      i[property] = list_item.css(property).text
    end
    list << i
  end
  Rake::Task["cs:get:path"].reenable
  list
end

def run(command)
  result = `#{command}`
  if $?.to_i == 0
    @log.info command
    puts command
  else
    result = result.gsub("\n", "\t")
    @log.error "#{command}\t#{result}"
    puts result
  end
end

##### TEMPLATE HELPERS

def clear_file(file)
  File.unlink file
  @log.info "Deleted: #{file}"
end

def get_config(config_file)
  raise "Invalid input file #{input_file}" unless File.file? config_file
  types = ["required", "optional", "generated"]
  fields = Hash.new { |hash, key| hash[key] = [] }
  CSV.foreach(config_file, {
      headers: true,
      header_converters: :symbol,
    }) do |row|
      data = row.to_hash
      raise "Type must be required or optional but was #{type}" unless types.include? data[:type]
      fields[:required] << data[:field] if data[:type] == "required"
      fields[:optional] << data[:field] if data[:type] == "optional"
      fields[:filename] << data[:field] if data[:filename] =~ /(^t|^true)/
  end
  raise "No required fields defined in #{config_file}" if fields[:required].empty?
  raise "Filename is undefined in #{config_file}" if fields[:filename].empty?
  fields[:generate]   = {}
  fields[:transforms] = {}
  fields
end

def get_short_identifier(value)
  v_str = value.gsub(/\W/, ''); # remove non-words
  v_enc = Base64.strict_encode64(v_str); # encode it
  v = v_str + v_enc.gsub(/\W/, ''); # remove non-words from result
  v
end

def get_template(file)
  File.read(file)
end

def print_fields(required, optional, generated = [])
  required.map{ |r| puts "#{r} * required" }
  puts optional
  generated.map{ |r| puts "#{r} * generated" }
end

def process_csv(input_file, output_dir, template_file, fields = {})
  raise "Invalid input file #{input_file}" unless File.file? input_file
  generated_values = Set.new
  CSV.foreach(input_file, {
      headers: true,
      header_converters: :symbol,
      converters: [:nil_to_empty, :xml_safe],
    }) do |row|

    data = row.to_hash
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

    # set the domain for cspace urn values
    data[:domain] = fields[:domain]

    # pp data
    template = ERB.new(get_template(template_file))
    result   = template.result(binding).gsub(/\n+/,"\n") # binding adds variables from scope

    output_filename = fields[:filename].inject("") { |fn, field| fn += data[field.to_sym] }
    write_file("#{output_dir}/#{output_filename}.xml", result)
  end
end

def write_csv(data)
  CSV.open('response.csv', 'w') do |csv|
    csv << data.first.keys
    data.each { |row| csv << row.values }
  end
end

def write_file(filename, data)
  File.open(filename, 'w') {|f| f.write(data) }
  @log.info "Created #{filename}"
end
