namespace :cs do

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

    # rake cs:relate:authorities[/locationauthorities/38cc1b61-a597-4b12-b820/items,locations,templates/relationships/hierarchies.example.csv]
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

end