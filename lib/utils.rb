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

##### TEMPLATE HELPERS

def clear_file(file)
  File.unlink file
  puts "Deleted: #{file}"
end

def get_template(file)
  File.read(file)
end

def print_fields(required, optional)
  required.map{ |r| puts "#{r} *" }
  puts optional
end

def process_csv(input_file, output_dir, template_file, required_fields = [], filename_fields = [])
  raise "Invalid input file #{input_file}" unless File.file? input_file
  CSV.foreach(input_file, {
      headers: true, :header_converters => :symbol, :converters => [:nil_to_empty]
    }) do |row|

    data = row.to_hash
    required_fields.each { |r| raise "HELL" unless data.has_key? r or ! data[r] }

    template = ERB.new(get_template(template_file))
    result   = template.result(binding) # binding adds variables from scope

    output_filename = filename_fields.inject("") { |fn, field| fn += data[field.to_sym] }
    File.open("#{output_dir}/#{output_filename}.xml", 'w') {|f| f.write(result) }
  end
end