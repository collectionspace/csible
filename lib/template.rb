# TEMPLATES
namespace :template do
  domain         = URI.parse(JSON.parse( IO.read('api.json') )["base"]).host
  surname_prefix = "([Dd]e|V[ao]n)"
  output_dir     = 'imports'

  namespace :cataloging do
    namespace :objects do
      config_file     = 'templates/cataloging/objects.config.csv'
      template_file   = 'templates/cataloging/object.xml.erb'
      fields          = get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        creator1_id: {
          from: :creator1_name,
          required: false,
          unique: true,
          process: :get_short_identifier,
        },
        creator2_id: {
          from: :creator2_name,
          required: false,
          unique: true,
          process: :get_short_identifier,
        },
      }

      fields[:transforms] = {
        date_period: ->(value) { value.capitalize },
        # prod_place: -> (value) { value.gsub(/\s/,'').split(",").map(&:capitalize).join(", ") },
      }

      # rake template:cataloging:objects:fields
      desc "Display fields for cataloging objects"
      task :fields do |t|
        print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cataloging:objects:process[templates/cataloging/objects.example.csv]
      desc "Create cataloging XML records from csv"
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
        print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:locations:items:process[templates/locations/onsite.csv]
      desc "Create location authority item XML records from csv"
      task :process, [:csv] do |t, args|
        process_csv(args[:csv], output_dir, template_file, fields)
      end
    end
  end

  namespace :persons do
    namespace :items do
      config_file     = 'templates/persons/items.config.csv'
      template_file   = 'templates/persons/item.xml.erb'
      fields          = get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        shortidentifier: {
          from: :name,
          required: true,
          unique: true,
          process: :get_short_identifier,
        },
        first: {
          from: :name,
          required: false,
          unique: false,
          process: ->(value) {
            name  = ""
            names = value.split(" ")
            name  = names[0] if names.length > 1
            name
          },
        },
        middle: {
          from: :name,
          required: false,
          unique: false,
          process: ->(value) {
            name  = ""
            names = value.split(" ")
            if names.length > 2
              first, middle, last = names
              name = middle unless middle =~ /#{surname_prefix}/
            end
            name
          },
        },
        last: {
          from: :name,
          required: false,
          unique: false,
          process: ->(value) {
            name  = ""
            names = value.split(" ")
            name  = names[-1] if names.length >= 2
            name  = "#{names[1]} #{name}" if names[1] =~ /#{surname_prefix}/
            name
          },
        },
      }

      # rake template:persons:items:fields
      desc "Display fields for person authority items"
      task :fields do |t|
        print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:persons:items:process[templates/persons/items.example.csv]
      desc "Create person authority item XML records from csv"
      task :process, [:csv] do |t, args|
        process_csv(args[:csv], output_dir, template_file, fields)
      end
    end

  end
end