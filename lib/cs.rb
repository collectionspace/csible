namespace :cs do
  base_command = "ansible-playbook -i 'localhost,' services.yml --extra-vars='@api.json'"

  # rake cs:cache[response.csv]
  desc "Add key value pairs to redis from csv"
  task :cache, [:csv] do |t, args|
    redis = Redis.new # fail if redis unavailable
    csv   = args[:csv]
    CSV.foreach(csv, {
        headers: true, :header_converters => :symbol, :converters => [:nil_to_empty]
      }) do |row|
      key, value = row.to_hash.values
      raise "Invalid csv values #{key} #{value}" if key.empty? or value.empty?
      redis.set(key, value)
    end
  end

  # rake cs:config
  desc "Dump csible config to terminal"
  task :config do |t, args|
    pp JSON.parse( IO.read('api.json') )
  end

  # rake cs:parse_xml["relation-list-item > uri"]
  desc "Parse xml for element value"
  task :parse_xml, [:element, :input, :output] do |t, args|
    element = args[:element]
    input   = args[:input] || "response.xml"
    output  = args[:output] || "response.txt"
    raise "HELL" unless File.file? input and File.file? output
    result  = get_element_values(input, element)
    write_file output, result.join("\n")
  end

  namespace :relate do
    output_dir = "tmp"

    # rake cs:relate:records[templates/relationships/relations.example.csv]
    desc "Create cataloging / procedure relationships using a csv file"
    task :records, [:csv, :throttle] do |t, args|
      redis    = Redis.new # fail if redis unavailable
      csv      = args[:csv]
      throttle = args[:throttle] || 0.10
      raise "HELL" unless File.file? csv
      template_file = "templates/relationships/relation.xml.erb"
      relationships = []
      # identifiers   = {}

      CSV.foreach(csv, {
          headers: true, :header_converters => :symbol, :converters => [:nil_to_empty]
        }) do |row|
        data = row.to_hash
        relationships << data
      end

      relationships.each do |relation|
        unless redis.get( relation[:from] )
          redis.set( relation[:from], get_csid(relation[:from_type], relation[:from_search], relation[:from], throttle) )
        end

        unless redis.get( relation[:to] )
          redis.set( relation[:to], get_csid(relation[:to_type], relation[:to_search], relation[:to], throttle) )
        end

        data = {}
        data[:from]      = relation[:from]
        data[:from_csid] = redis.get( relation[:from] )
        data[:from_type] = relation[:from_type]
        data[:to]        = relation[:to]
        data[:to_csid]   = redis.get( relation[:to] )
        data[:to_type]   = relation[:to_type]

        template  = ERB.new(get_template(template_file))
        result    = template.result(binding)

        # cache result and filename
        filename        = "#{data[:from]}_#{data[:to]}".gsub(/ /, '')
        output_filename = "#{output_dir}/#{filename}-1.xml"
        write_file(output_filename, result)

        # now invert for the reciprocal relationship
        data[:from]      = relation[:to]
        data[:from_csid] = redis.get( relation[:to] )
        data[:from_type] = relation[:to_type]
        data[:to]        = relation[:from]
        data[:to_csid]   = redis.get( relation[:from] )
        data[:to_type]   = relation[:from_type]

        template  = ERB.new(get_template(template_file))
        result    = template.result(binding)

        # cache result
        output_filename = "#{output_dir}/#{filename}-2.xml"
        write_file(output_filename, result)
      end
    end

    # rake cs:relate:authorities[/locationauthorities/38cc1b61-a597-4b12-b820/items,locations,templates/relationships/relationships.example.csv]
    desc "Set and PUT authority relationships using a csv file"
    task :authorities, [:path, :type, :csv] do |t, args|
      path = args[:path]
      type = args[:type]
      csv  = args[:csv]
      raise "HELL" unless File.file? csv
      # TODO: replace with 'singularize'
      raise "Unknown itemtype for authority #{type}" unless authority_itemtypes(type)

      template_file = "templates/relationships/hierarchy.xml.erb"
      relationships = Hash.new { |hash, key| hash[key] = [] }
      identifiers   = Hash.new { |hash, key| hash[key] = {} }

      CSV.foreach(csv, {
          headers: true, :header_converters => :symbol, :converters => [:nil_to_empty]
        }) do |row|
        data = row.to_hash
        next if data[:to].empty? or data[:from].empty? # undefined relationship
        relationships[data[:to]] << data[:from]
      end

      relationships.each do |broad, related|
        broad_id = get_short_identifier(broad)
        ids = get_identifiers(path, broad_id)
        raise "Invalid relationship #{broad_id} does not exist." unless ids
        identifiers[broad] = ids
        related.each do |item|
          item_id = get_short_identifier(item)
          ids  = get_identifiers(path, item_id)
          raise "Invalid relationship #{item_id} does not exist." unless ids
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
          write_file(output_filename, result)

          # make the introductions
          Rake::Task["cs:put:file"].invoke(identifiers[item]["uri"], output_filename)
          Rake::Task["cs:put:file"].reenable
        end
      end
    end
  end

  namespace :get do

    # rake cs:get:path[/locationauthorities]
    desc "GET request by path"
    task :path, [:path, :params] do |t, args|
      path   = args[:path]
      params = args[:params] || nil
      run command(base_command, 'GET', { path: path, params: params })
    end

    # rake cs:get:url[https://cspace.lyrasistechnology.org/cspace-services/locationauthorities]
    desc "GET request by url"
    task :url, [:url] do |t, args|
      url    = args[:url]
      run command(base_command, 'GET', { url: url })
    end

    # rake cs:get:list[/media,uri~csid,"wf_deleted=false&pgSz=100"]
    desc "GET request by path for results list to csv specifying properties"
    task :list, [:path, :properties, :params, :output] do |t, args|
      path       = args[:path]
      properties = args[:properties] || [ "uri" ]
      properties = properties.split("~") if properties.respond_to? :split
      params     = args[:params] || nil
      output     = args[:output] || "response.csv"
      results    = get_list_properties(path, properties, params)
      write_csv(output, results) unless results.empty?
    end

  end

  namespace :post do

    # rake cs:post:directory[/locationauthorities/XYZ/items,examples/locations,1]
    desc "POST requests by path using directory of files to import"
    task :directory, [:path, :directory, :throttle] do |t, args|
      path      = args[:path]
      directory = args[:directory]
      throttle  = args[:throttle] || 1

      raise "Invalid directory" unless File.directory? directory

      Dir["#{args[:directory]}/*.xml"].each do |file|
        Rake::Task["cs:post:file"].invoke(path, file)
        `sleep #{throttle}`
        Rake::Task["cs:post:file"].reenable
      end
    end

    # rake cs:post:file[/locationauthorities/XYZ/items,examples/locations/1.xml]
    desc "POST request by path using file to import"
    task :file, [:path, :file] do |t, args|
      path = args[:path]
      file = args[:file]
      raise "Invalid file" unless File.file? file
      run command(base_command, 'POST', { path: path, file: file })
      File.unlink file
    end

  end

  namespace :put do

    # rake cs:put:file[/locationauthorities/XYZ/items/ABC,examples/locations/1.xml]
    desc "PUT request by path with file of updated metadata"
    task :file, [:path, :file] do |t, args|
      path = args[:path]
      file = args[:file]
      raise "Invalid file" unless File.file? file
      run command(base_command, 'PUT', { path: path, file: file })
    end

  end

  namespace :delete do

    desc "DELETE request by path"
    task :path, [:path] do |t, args|
      path = args[:path]
      run command(base_command, 'DELETE', { path: path })
    end

    desc "DELETE request by url"
    task :url, [:url] do |t, args|
      url = args[:url]

      protocol = URI.parse( JSON.parse( IO.read('api.json') )["base"] ).scheme

      url = url.gsub(/https?:/, "#{protocol}:") if protocol !~ /url/
      run command(base_command, 'DELETE', { url: url })
    end

    # rake cs:delete:file[deletes.txt]
    # rake cs:delete:file[deletes.txt,path,1]
    desc "DELETE requests by file of urls or paths"
    task :file, [:file, :type, :throttle] do |t, args|
      file      = args[:file]
      type      = args[:type] || "url"
      throttle  = args[:throttle] || 1
      raise "HELL" unless File.file? file
      File.readlines(file).each do |line|
        Rake::Task["cs:delete:#{type}"].invoke(line)
        `sleep #{throttle}`
        Rake::Task["cs:delete:#{type}"].reenable
      end
    end

  end

  namespace :update do
    output_dir = "tmp"

    # rake cs:update:generate[templates/updates/update-id.example.csv,tmp.csv]
    desc "Generate request csv from csv containing id w/o uri using redis"
    task :generate, [:csv, :output] do |t, args|
      csv             = args[:csv]
      generated       = []
      output_filename = args[:output] || "response.csv"
      redis           = Redis.new
      raise "HELL" unless File.file? csv
      CSV.foreach(csv, {
          headers: true, :header_converters => :symbol, :converters => [:nil_to_empty]
        }) do |row|
        data = row.to_hash
        uri  = redis.get( data[:id] )
        raise "Invalid id #{data[:id]}" unless uri
        data[:uri] = uri
        generated << data
      end
      write_csv(output_filename, generated)
    end

    # rake cs:update:nested[templates/updates/update-nested.example.csv]
    desc "Update requests by csv with nested template"
    task :nested, [:csv] do |t, args|
      csv           = args[:csv]
      template_file = "templates/updates/update-nested.xml.erb"
      Rake::Task["cs:update:template"].invoke(csv, template_file)
      Rake::Task["cs:update:template"].reenable
    end

    # rake cs:update:process[templates/updates/update.example.csv]
    # rake cs:update:process[templates/updates/update-nested.example.csv]
    desc "Process update templates"
    task :process, [:csv, :throttle] do |t, args|
      csv           = args[:csv]
      throttle      = args[:throttle] || 0.10
      CSV.foreach(csv, {
          headers: true, :header_converters => :symbol, :converters => [:nil_to_empty]
        }) do |row|
        data = row.to_hash
        output_filename = "#{output_dir}/#{data[:element]}-#{data[:uri].split("/")[-1]}.xml"
        if File.file? output_filename
          Rake::Task["cs:put:file"].invoke(data[:uri], output_filename)
          `sleep #{throttle}`
          Rake::Task["cs:put:file"].reenable
        end
      end
    end

    # rake cs:update:template[templates/updates/update.example.csv]
    desc "Update requests by csv"
    task :template, [:csv, :template] do |t, args|
      csv           = args[:csv]
      template_file = args[:template] || "templates/updates/update.xml.erb"
      raise "HELL" unless File.file? csv and File.file? template_file
      CSV.foreach(csv, {
          headers: true, :header_converters => :symbol, :converters => [:nil_to_empty]
        }) do |row|
        data = row.to_hash

        template = ERB.new(get_template(template_file))
        result   = template.result(binding)

        # cache result
        output_filename = "#{output_dir}/#{data[:element]}-#{data[:uri].split("/")[-1]}.xml"
        write_file(output_filename, result)
      end
    end
  end

end