# TEMPLATES
namespace :template do
  domain         = JSON.parse( IO.read('api.json') )["urn"]
  surname_prefix = "([Dd]e|V[ao]n)"
  output_dir     = 'imports'

  namespace :acquisitions do
    namespace :objects do
      config_file     = 'templates/acquisitions/objects.config.csv'
      template_file   = 'templates/acquisitions/object.xml.erb'
      fields          = get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        currency_id: {
          from: :currency,
          required: false,
          unique: false,
          process: :get_currency_code,
        },
        source_id: {
          from: :source,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        owner_id: {
          from: :owner,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
      }

      # rake template:acquisitions:objects:fields
      desc "Display fields for acquisitions objects"
      task :fields do |t|
        print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:acquisitions:objects:process[templates/acquisitions/objects.example.csv]
      desc "Create acquisitions XML records from csv"
      task :process, [:csv] do |t, args|
        process_csv(args[:csv], output_dir, template_file, fields)
      end
    end
  end

  namespace :cataloging do
    namespace :objects do
      config_file     = 'templates/cataloging/objects.config.csv'
      template_file   = 'templates/cataloging/object.xml.erb'
      fields          = get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        concept1_id: {
          from: :concept1_name,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        concept2_id: {
          from: :concept2_name,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        creator1_id: {
          from: :creator1_name,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        creator2_id: {
          from: :creator2_name,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        provenance_id: {
          from: :provenance,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
      }

      fields[:transforms] = {
        concept1_name: ->(value) { value.capitalize },
        concept2_name: ->(value) { value.capitalize },
        date_period: ->(value) { value.capitalize },
        # prod_place: -> (value) { value.gsub(/\s/,'').split(",").map(&:capitalize).join(", ") },
        title: ->(value) { value.capitalize },
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

  namespace :conditioncheck do
    namespace :objects do
      config_file     = 'templates/conditioncheck/objects.config.csv'
      template_file   = 'templates/conditioncheck/object.xml.erb'
      fields          = get_config(config_file)
      fields[:domain] = domain

      fields[:filter] = {
        # note: ->(value) { value.nil? or value.empty? },
      }

      # rake template:conditioncheck:objects:fields
      desc "Display fields for conditioncheck objects"
      task :fields do |t|
        print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:conditioncheck:objects:process[templates/conditioncheck/objects.example.csv]
      desc "Create conditioncheck XML records from csv"
      task :process, [:csv] do |t, args|
        process_csv(args[:csv], output_dir, template_file, fields)
      end
    end
  end

  namespace :concepts do
    namespace :items do
      config_file     = 'templates/concepts/items.config.csv'
      template_file   = 'templates/concepts/item.xml.erb'
      fields          = get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        shortidentifier: {
          from: :name,
          required: true,
          unique: true,
          process: :get_short_identifier,
        },
      }

      fields[:transforms] = {
        name: ->(value) { value.capitalize },
      }

      # rake template:concepts:items:fields
      desc "Display fields for concept authority items"
      task :fields do |t|
        print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:concepts:items:process[templates/concepts/items.example.csv]
      desc "Create concept authority item XML records from csv"
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
              name = middle unless middle =~ /^#{surname_prefix}/
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
            name  = "#{names[1]} #{name}" if names[1] =~ /^#{surname_prefix}/
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

  namespace :valuationcontrol do
    namespace :objects do
      config_file     = 'templates/valuationcontrol/objects.config.csv'
      template_file   = 'templates/valuationcontrol/object.xml.erb'
      fields          = get_config(config_file)
      fields[:domain] = domain

      fields[:filter] = {
        # value: ->(value) { value.nil? or value.empty? },
      }

      fields[:generate] = {
        currency_id: {
          from: :currency,
          required: false,
          unique: false,
          process: :get_currency_code,
        },
      }

      # rake template:valuationcontrol:objects:fields
      desc "Display fields for valuationcontrol objects"
      task :fields do |t|
        print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:valuationcontrol:objects:process[templates/valuationcontrol/objects.example.csv]
      desc "Create valuationcontrol XML records from csv"
      task :process, [:csv] do |t, args|
        process_csv(args[:csv], output_dir, template_file, fields)
      end
    end
  end
end