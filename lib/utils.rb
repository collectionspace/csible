##### CSV helpers

CSV::Converters[:nil_to_empty] = lambda do |field|
  field ? field : ""
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
    sh "sleep #{throttle}"
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

##### TEMPLATE HELPERS

def clear_file(file)
  File.unlink file
  puts "Deleted: #{file}"
end

def get_config(config_file)
  raise "Invalid input file #{input_file}" unless File.file? config_file
  types = ["required", "optional"]
  fields = Hash.new { |hash, key| hash[key] = [] }
  CSV.foreach(config_file, {
      headers: true, :header_converters => :symbol, :converters => [:nil_to_empty]
    }) do |row|
      data = row.to_hash
      raise "Type must be required or optional but was #{type}" unless types.include? data[:type]
      fields[:required] << data[:field] if data[:type] == "required"
      fields[:optional] << data[:field] if data[:type] == "optional"
      fields[:filename] << data[:field] if data[:filename] =~ /(^t|^true)/
  end
  raise "No required fields defined in #{config_file}" if fields[:required].empty?
  raise "Filename is undefined in #{config_file}" if fields[:filename].empty?
  fields
end

def get_template(file)
  File.read(file)
end

def print_fields(required, optional)
  required.map{ |r| puts "#{r} *" }
  puts optional
end

def process_csv(input_file, output_dir, template_file, fields = {})
  raise "Invalid input file #{input_file}" unless File.file? input_file
  CSV.foreach(input_file, {
      headers: true, :header_converters => :symbol, :converters => [:nil_to_empty]
    }) do |row|

    data = row.to_hash
    # check required fields have value and pad optional fields to allow partial csv
    fields[:required].each { |r| raise "HELL" unless data.has_key? r.to_sym or data[r.to_sym].empty? }
    fields[:optional].each { |r| data[r] = "" unless data.has_key? r.to_sym }

    template = ERB.new(get_template(template_file))
    result   = template.result(binding) # binding adds variables from scope

    output_filename = fields[:filename].inject("") { |fn, field| fn += data[field.to_sym] }
    File.open("#{output_dir}/#{output_filename}.xml", 'w') {|f| f.write(result) }
  end
end

def write_csv(data)
  CSV.open('response.csv', 'w') do |csv|
    csv << data.first.keys
    data.each { |row| csv << row.values }
  end
end