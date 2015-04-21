# TEMPLATES
namespace :template do
  domain     = URI.parse(JSON.parse( IO.read('api.json') )["base"]).host
  output_dir = 'imports'

  namespace :cataloging do
    namespace :objects do
      config_file     = 'templates/cataloging/objects.config.csv'
      template_file   = 'templates/cataloging/object.xml.erb'
      fields          = get_config(config_file)
      fields[:domain] = domain

      fields[:transforms] = {
        date_period: ->(value) { value.capitalize }
      }

      # rake template:cataloging:objects:fields
      desc "Display fields for cataloging objects"
      task :fields do |t|
        print_fields fields[:required], fields[:optional]
      end

      # rake template:cataloging:objects:process[templates/cataloging/objects.example.csv]
      desc "Create location authority item XML records from csv"
      task :process, [:csv] do |t, args|
        process_csv(args[:csv], output_dir, template_file, fields)
      end
    end
  end

  namespace :locations do
    namespace :authorities do
      # todo
      # rake template:locations:authorities:process[templates/locations/authorities.example.csv]
    end

    namespace :items do
      config_file     = 'templates/locations/items.config.csv'
      template_file   = 'templates/locations/item.xml.erb'
      fields          = get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        shortidentifier: {
          from: :termname,
          required: true,
          unique: true,
          process: :get_short_identifier,
        },
      }

      # rake template:locations:items:fields
      desc "Display fields for location authority items"
      task :fields do |t|
        print_fields fields[:required], fields[:optional]
      end

      # rake template:locations:items:process[templates/locations/onsite.csv]
      desc "Create location authority item XML records from csv"
      task :process, [:csv] do |t, args|
        process_csv(args[:csv], output_dir, template_file, fields)
      end
    end
  end
end