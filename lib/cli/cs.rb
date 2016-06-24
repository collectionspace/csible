namespace :cs do
  $config = Csible.get_config('api.json')
  $client = Csible.get_client( $config[:services] )
  $log    = $config[:logging][:method] == 'file' ?
    Logger.new(File.open('response.log', 'a+')) : Logger.new(STDOUT)

  # rake cs:cache[response.csv]
  desc "Add key value pairs to redis from csv"
  task :cache, [:csv] do |t, args|
    redis = Redis.new # fail if redis unavailable
    csv   = args[:csv]
    CSV.foreach(csv, {
        headers: true,
        header_converters: ->(header) { header.to_sym },
      }) do |row|
      key, value = row.to_hash.values
      raise "Invalid csv values #{key} #{value}" if key.empty? or value.empty?
      redis.set(key, value)
    end
  end

  # rake cs:config
  desc "Dump csible config to terminal"
  task :config do |t, args|
    ap $config
  end

  # rake cs:initialize[core]
  desc "Initialize authorities for tenant"
  task :initialize do |t, args|
    tenant = args[:tenant] || 'core'
    path   = "collectionspace/tenant/#{tenant}/authorities/initialise"
    url    = $config[:services][:base_uri].gsub("cspace-services", path)
    req    = Csible::HTTP::Request.new($client, $log)
    begin
      req.do_raw :get, url, {}
    rescue Exception => ex
      $log.error ex.message
    end
  end

  # rake cs:parse_xml["relation-list-item > uri"]
  desc "Parse xml for element value"
  task :parse_xml, [:element, :input, :output] do |t, args|
    element = args[:element]
    input   = args[:input] || "response.xml"
    output  = args[:output] || "response.txt"
    raise "HELL" unless File.file? input and File.file? output
    result  = Csible.get_element_values(input, element)
    Csible.write_file output, result.join("\n", $log)
  end

  namespace :relate do
    output_dir     = "tmp"
    templates_path = $config[:templates][:templates_path] ||= "templates"

    # rake cs:relate:records[templates/relationships/relations.example.csv]
    desc "Create cataloging / procedure relationships using a csv file"
    task :records, [:csv] do |t, args|
      redis    = Redis.new # fail if redis unavailable
      csv      = args[:csv]
      raise "HELL" unless File.file? csv
      template_file = "templates/collectionspace/relationships/relation.xml.erb"
      relationships = []
      get           = Csible::HTTP::Get.new($client, $log)

      CSV.foreach(csv, {
          headers: true,
          header_converters: ->(header) { header.to_sym },
        }) do |row|
        data = row.to_hash
        relationships << data
      end

      relationships.each do |relation|
        begin
          unless redis.get( relation[:from] )
            redis.set( relation[:from], get.csid_for(relation[:from_type], relation[:from_search], relation[:from]) )
          end

          unless redis.get( relation[:to] )
            redis.set( relation[:to], get.csid_for(relation[:to_type], relation[:to_search], relation[:to]) )
          end

          data = {}
          data[:from]      = relation[:from]
          data[:from_csid] = redis.get( relation[:from] )
          data[:from_type] = relation[:from_type]
          data[:to]        = relation[:to]
          data[:to_csid]   = redis.get( relation[:to] )
          data[:to_type]   = relation[:to_type]

          template  = Csible.get_template template_file
          result    = template.result(binding)

          # cache result and filename
          filename        = "#{data[:from]}_#{data[:to]}".gsub(/ /, '')
          output_filename = "#{output_dir}/#{filename}-1.xml"
          Csible.write_file(output_filename, result, $log)

          # now invert for the reciprocal relationship
          data[:from]      = relation[:to]
          data[:from_csid] = redis.get( relation[:to] )
          data[:from_type] = relation[:to_type]
          data[:to]        = relation[:from]
          data[:to_csid]   = redis.get( relation[:from] )
          data[:to_type]   = relation[:from_type]

          template  = Csible.get_template template_file
          result    = template.result(binding)

          # cache result
          output_filename = "#{output_dir}/#{filename}-2.xml"
          Csible.write_file(output_filename, result, $log)
        rescue Exception => ex
          $log.error ex.message
        end
      end
    end

    # rake cs:relate:authorities[/locationauthorities/38cc1b61-a597-4b12-b820/items,locations,templates/relationships/relationships.example.csv]
    desc "Set and PUT authority relationships using a csv file"
    task :authorities, [:path, :type, :csv] do |t, args|
      path = args[:path]
      type = args[:type]
      csv  = args[:csv]
      raise "HELL" unless File.file? csv

      template_file = "templates/collectionspace/relationships/hierarchy.xml.erb"
      relationships = Hash.new { |hash, key| hash[key] = [] }
      identifiers   = Hash.new { |hash, key| hash[key] = {} }
      get           = Csible::HTTP::Get.new($client, $log)
      processor     = Csible::CSV::Processor.new('', '', '') # for helpers

      # TODO: replace with 'singularize'
      raise "Unknown itemtype for authority #{type}" unless processor.authority_itemtypes(type)

      CSV.foreach(csv, {
          headers: true,
          header_converters: ->(header) { header.to_sym },
        }) do |row|
        data = row.to_hash
        next if data[:to].empty? or data[:from].empty? # undefined relationship
        relationships[data[:to]] << data[:from]
      end

      relationships.each do |broad, related|
        begin
          broad_id = processor.get_short_identifier(broad)
          ids = get.identifiers_for(path, broad_id)
          raise "Invalid relationship #{broad_id} does not exist." unless ids
          identifiers[broad] = ids
          related.each do |item|
            item_id = processor.get_short_identifier(item)
            ids  = get.identifiers_for(path, item_id)
            raise "Invalid relationship #{item_id} does not exist." unless ids
            identifiers[item] = ids

            # wrap data for template
            data = {}
            data[:type]     = type
            data[:itemtype] = processor.authority_itemtypes(type)
            data[:csid]     = identifiers[broad]["csid"]
            data[:uri]      = identifiers[broad]["uri"]

            template = Csible.get_template template_file
            result   = template.result(binding)

            # cache result
            output_filename = "#{output_dir}/#{identifiers[item]["csid"]}.xml"
            Csible.write_file(output_filename, result, $log)

            # make the introductions
            Rake::Task["cs:put:file"].invoke("#{identifiers[item]["uri"].gsub(/^\//, '')}", output_filename)
            Rake::Task["cs:put:file"].reenable
          end
        rescue Exception => ex
          $log.error ex.message
        end
      end
    end

    # rake cs:relate:contacts[personauthorities/e3308f39-d3dc-46f8-a1f8/items,templates/persons/item.example.csv]
    desc "Create contact records for authorities from a csv file"
    task :contacts, [:path, :csv, :identifier_field] do |t, args|
      path             = args[:path]
      csv              = args[:csv]
      identifier_field = (args[:identifier_field] || 'termDisplayName').to_sym
      raise "HELL" unless File.file? csv

      config_file   = "#{templates_path}/collectionspace/relationships/contact.config.csv"
      template_file = "#{templates_path}/collectionspace/relationships/contact.xml.erb"
      fields        = Csible::CSV.get_config(config_file)

      get           = Csible::HTTP::Get.new($client, $log)
      processor     = Csible::CSV::Processor.new(csv, output_dir, template_file, fields) # for fields and helpers
      processor.run do |data|
        id_val   = data[identifier_field]
        short_id = processor.get_short_identifier(id_val)
        ids      = get.identifiers_for(path, short_id)
        if ids
          template = Csible.get_template template_file
          result   = template.result(binding)

          # cache result
          output_filename = "#{output_dir}/#{ids["csid"]}-contact.xml"
          Csible.write_file(output_filename, result, $log)

          # add the contact
          Rake::Task["cs:post:file"].invoke("#{ids["uri"].gsub(/^\//, '')}/contacts", output_filename)
          Rake::Task["cs:post:file"].reenable
        else
          $log.warn "Unable to find record for #{short_id}"
        end
      end
    end
  end

  namespace :get do

    # rake cs:get:path[locationauthorities]
    desc "GET request by path"
    task :path, [:path, :format, :params] do |t, args|
      path   = args[:path]
      format = (args[:format] || 'json').to_sym
      params = Csible::HTTP.convert_params(args[:params]  || '')
      get    = Csible::HTTP::Get.new($client, $log)
      begin
        get.execute :path, path, params
        get.print format
      rescue Exception => ex
        $log.error ex.message
      end
    end

    # rake cs:get:url[https://cspace.lyrasistechnology.org/cspace-services/locationauthorities]
    desc "GET request by url"
    task :url, [:url, :format, :params] do |t, args|
      url    = args[:url]
      format = (args[:format] || 'json').to_sym
      params = Csible::HTTP.convert_params(args[:params]  || '')
      get    = Csible::HTTP::Get.new($client, $log)
      begin
        get.execute :url, url, params
        get.print format
      rescue Exception => ex
        $log.error ex.message
      end

    end

    # rake cs:get:list[media,"wf_deleted=false&pgSz=100"]
    desc "GET request by path for results list to csv specifying properties"
    task :list, [:path, :params, :output] do |t, args|
      path       = args[:path]
      params     = Csible::HTTP.convert_params(args[:params]  || '')
      output     = args[:output] || "response.csv"
      get        = Csible::HTTP::Get.new($client, $log)
      results    = get.list path, params
      File.truncate(output, 0)
      Csible.write_csv(output, results, $log) unless results.empty?
    end

  end

  namespace :post do

    # rake cs:post:directory[locationauthorities/XYZ/items,examples/locations]
    desc "POST requests by path using directory of files to import"
    task :directory, [:path, :directory] do |t, args|
      path      = args[:path]
      directory = args[:directory]

      raise "Invalid directory" unless File.directory? directory

      Dir["#{args[:directory]}/*.xml"].each do |file|
        Rake::Task["cs:post:file"].invoke(path, file)
        Rake::Task["cs:post:file"].reenable
      end
    end

    # rake cs:post:file[locationauthorities/XYZ/items,examples/locations/1.xml]
    desc "POST request by path using file to import"
    task :file, [:path, :file] do |t, args|
      path = args[:path]
      file = args[:file]
      raise "Invalid file" unless File.file? file
      payload = File.read(file)
      post    = Csible::HTTP::Post.new($client, $log)
      begin
        post.execute :path, path, payload
        File.unlink file
      rescue Exception => ex
        $log.error ex.message
      end
    end

  end

  namespace :put do

    # rake cs:put:file[locationauthorities/XYZ/items/ABC,examples/locations/1.xml]
    desc "PUT request by path with file of updated metadata"
    task :file, [:path, :file] do |t, args|
      path = args[:path]
      file = args[:file]
      raise "Invalid file" unless File.file? file
      payload = File.read(file)
      put     = Csible::HTTP::Put.new($client, $log)
      begin
        put.execute :path, path, payload
        File.unlink file
      rescue Exception => ex
        $log.error ex.message
      end
    end

  end

  namespace :delete do

    desc "DELETE request by path"
    task :path, [:path] do |t, args|
      path   = args[:path]
      delete = Csible::HTTP::Delete.new($client, $log)
      begin
        delete.execute :path, path
      rescue Exception => ex
        $log.error ex.message
      end
    end

    desc "DELETE request by url"
    task :url, [:url] do |t, args|
      url      = args[:url]
      protocol = URI.parse( $client.config.base_uri ).scheme
      url      = url.gsub(/https?:/, "#{protocol}:") if protocol !~ /#{url}/
      delete   = Csible::HTTP::Delete.new($client, $log)
      begin
        delete.execute :url, url
      rescue Exception => ex
        $log.error ex.message
      end
    end

    # rake cs:delete:file[deletes.txt]
    # rake cs:delete:file[deletes.txt,path]
    desc "DELETE requests by file of urls or paths"
    task :file, [:file, :type, :throttle] do |t, args|
      file      = args[:file]
      type      = args[:type] || "url"
      raise "HELL" unless File.file? file
      File.readlines(file).each do |line|
        Rake::Task["cs:delete:#{type}"].invoke(line)
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
          headers: true,
          header_converters: ->(header) { header.to_sym },
        }) do |row|
        data = row.to_hash
        uri  = redis.get( data[:id] )
        raise "Invalid id #{data[:id]}" unless uri
        data[:uri] = uri
        generated << data
      end
      Csible.write_csv(output_filename, generated, $log)
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
          headers: true,
          header_converters: ->(header) { header.to_sym },
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
          headers: true,
          header_converters: ->(header) { header.to_sym },
        }) do |row|
        data = row.to_hash

        template = Csible.get_template template_file
        result   = template.result(binding)

        # cache result
        output_filename = "#{output_dir}/#{data[:element]}-#{data[:uri].split("/")[-1]}.xml"
        Csible.write_file(output_filename, result, $log)
      end
    end
  end

end
