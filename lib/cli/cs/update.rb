namespace :cs do

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