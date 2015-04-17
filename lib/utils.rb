# helpers
CSV::Converters[:nil_to_empty] = lambda do |field|
  field ? field : ""
end

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