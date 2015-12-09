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
    "places" => "Placeitem",
    "concepts" => "Conceptitem",
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

def get_csid(type, param, value, throttle = 0.25)
  params = "as=#{type}_common:#{param}%3D%22#{value.gsub(/ /, "+")}%22&wf_deleted=false"
  Rake::Task["cs:get:path"].invoke("/#{type}", params)
  response = Nokogiri::XML.parse(File.open("response.xml"))
  total_items = response.css("totalItems").text.to_i
  raise "Search result != 1 for #{type} #{param} #{value}" unless total_items == 1
  csid = response.css("csid").text
  `sleep #{throttle}`
  Rake::Task["cs:get:path"].reenable
  csid
end

def get_element_values(file, element)
  response = Nokogiri::XML.parse(File.open(file))
  values = response.css(element).map(&:text)
  values
end

def get_identifiers(path, id, throttle = 0.25)
  identifiers = {}
  Rake::Task["cs:get:path"].invoke(path, "kw=#{id}")
  response    = Nokogiri::XML.parse(File.open("response.xml"))
  total_items = response.css("totalItems").text.to_i
  if total_items == 1
    identifiers["csid"] = response.css("csid").text
    identifiers["uri"]  = response.css("uri").text
  else
    identifiers = nil
  end
  `sleep #{throttle}`
  Rake::Task["cs:get:path"].reenable
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
  raise "Invalid input file #{config_file}" unless File.file? config_file
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
  fields[:filter]     = {}
  fields[:generate]   = {}
  fields[:transforms] = {}
  fields
end

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

def get_placetype_refname(value)
  # Example, urn:cspace:collection.watermillcenter.org:vocabularies:name(placetermtype):item:name(country_code)'Country code'
  urn_str = JSON.parse( IO.read('api.json') )["urn"]
  shortid_str = value.gsub(/\W/, '_'); # remove non-words
  refname_str = "urn:cspace:" + urn_str + ":vocabularies:name(placetermtype):item:name(" + shortid_str.downcase + ")'" + value + "'";
  refname_str
end

def get_place_refname(value)
  # Example, urn:cspace:collection.watermillcenter.org:placeauthorities:name(place):item:name(Oakland1449274470100)'Oakland'
  shortid_str = get_short_identifier(value);
  shortid_str = shortid_str.gsub(/\W/, '_'); # remove non-words
  shortid_str = shortid_str.gsub(/'/, '\'\''); # add SQL escape char to single quote char
  urn_str = JSON.parse( IO.read('api.json') )["urn"]
  refname_str = "urn:cspace:" + urn_str + ":placeauthorities:name(place):item:name(" + shortid_str.downcase + ")''" + value + "''"; # Need to double up single quote chars for SQL
  refname_str
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
      header_converters: lambda { |h| h.to_sym },
      converters: [:nil_to_empty, :xml_safe],
    }) do |row|

    data = row.to_hash

    # process filters (skip if filter)
    skip = false
    fields[:filter].each do |filter, spec|
      skip = true if spec.call(data[filter])
      break if skip
    end
    next if skip

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
    output_filename = output_filename.gsub(/\s+/, "")
    write_file("#{output_dir}/#{output_filename}.xml", result)
  end
end

def write_csv(filename, data)
  CSV.open(filename, 'w') do |csv|
    csv << data.first.keys
    data.each { |row| csv << row.values }
  end
end

def write_file(filename, data)
  File.open(filename, 'w') {|f| f.write(data) }
  @log.info "Created #{filename}"
end
