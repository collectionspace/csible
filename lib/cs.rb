# helpers

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

namespace :cs do
  desc "Run csible commands"

  base_command = "ansible-playbook -i 'localhost,' services.yml --extra-vars='@api.json'"

  # rake cs:config
  task :config do |t, args|
    pp JSON.parse( IO.read('api.json') )
  end

  # rake cs:relationships[/locationauthorities/38cc1b61-a597-4b12-b820/items,locations,templates/relationships/relationships.example.csv]
  task :relationships, [:path, :type, :csv] do |t, args|
    path = args[:path]
    type = args[:type]
    csv  = args[:csv]
    raise "HELL" unless File.file? csv
    raise "Unknown itemtype for authority #{type}" unless authority_itemtypes(type)

    output_dir    = "tmp"
    template_file = "templates/relationships/relationship.xml.erb"
    relationships = Hash.new { |hash, key| hash[key] = [] }
    identifiers   = Hash.new { |hash, key| hash[key] = {} }

    CSV.foreach(csv, {
        headers: true, :header_converters => :symbol, :converters => [:nil_to_empty]
      }) do |row|
      data = row.to_hash
      relationships[data[:to]] << data[:from]
    end

    relationships.each do |broad, related|
      ids = get_identifiers(path, broad)
      raise "Invalid relationship #{broad} does not exist." unless ids
      identifiers[broad] = ids
      related.each do |item|
        ids  = get_identifiers(path, item)
        raise "Invalid relationship #{item} does not exist." unless ids
        identifiers[item] = ids

        # wrap data for template
        data = {}
        data[:type]     = type
        data[:itemtype] = authority_itemtypes(type)
        data[:csid]     = identifiers[broad]["csid"]
        data[:uri]      = identifiers[broad]["uri"]

        template = ERB.new(get_template(template_file))
        result   = template.result(binding)

        # cache result
        output_filename = "#{output_dir}/#{identifiers[item]["csid"]}.xml"
        File.open(output_filename, 'w') {|f| f.write(result) }

        # make the introductions
        Rake::Task["cs:put:file"].invoke(identifiers[item]["uri"], output_filename)
        Rake::Task["cs:put:file"].reenable
      end
    end
  end

  namespace :get do

    # rake cs:get:path[/locationauthorities]
    task :path, [:path, :params] do |t, args|
      path   = args[:path]
      params = args[:params] || nil
      sh command(base_command, 'GET', { path: path, params: params })
    end

    # rake cs:get:url[https://cspace.lyrasistechnology.org/cspace-services/locationauthorities]
    task :url, [:url] do |t, args|
      url    = args[:url]
      sh command(base_command, 'GET', { url: url })
    end

  end

  namespace :post do

    # rake cs:post:directory[/locationauthorities/XYZ/items,examples/locations,1]
    task :directory, [:path, :directory, :throttle] do |t, args|
      path      = args[:path]
      directory = args[:directory]
      throttle  = args[:throttle] || 1

      raise "Invalid directory" unless File.directory? directory

      Dir["#{args[:directory]}/*.xml"].each do |file|
        Rake::Task["cs:post:file"].invoke(path, file)
        sh "sleep #{throttle}"
        Rake::Task["cs:post:file"].reenable
      end
    end

    # rake cs:post:file[/locationauthorities/XYZ/items,examples/locations/1.xml]
    task :file, [:path, :file] do |t, args|
      path = args[:path]
      file = args[:file]
      raise "Invalid file" unless File.file? file
      sh command(base_command, 'POST', { path: path, file: file })
    end

  end

  namespace :put do

    # rake cs:put:file[/locationauthorities/XYZ/items/ABC,examples/locations/1.xml]
    task :file, [:path, :file] do |t, args|
      path = args[:path]
      file = args[:file]
      raise "Invalid file" unless File.file? file
      sh command(base_command, 'PUT', { path: path, file: file })
    end

  end

  namespace :delete do

    task :path, [:path] do |t, args|
      path = args[:path]
      sh command(base_command, 'DELETE', { path: path })
    end

    task :url, [:url] do |t, args|
      url = args[:url]
      url = url.gsub(/http:/, 'https:') # always https
      sh command(base_command, 'DELETE', { url: url })
    end

    # rake cs:delete:file[deletes.txt]
    # rake cs:delete:file[deletes.txt,path,1]
    task :file, [:file, :type, :throttle] do |t, args|
      file      = args[:file]
      type      = args[:type] || "url"
      throttle  = args[:throttle] || 1
      raise "HELL" unless File.file? file
      File.readlines(file).each do |line|
        Rake::Task["cs:delete:#{type}"].invoke(line)
        sh "sleep #{throttle}"
        Rake::Task["cs:delete:#{type}"].reenable
      end
    end

  end

end