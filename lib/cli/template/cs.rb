# TEMPLATES
namespace :template do
  namespace :cs do

    $config        = Csible.get_config('api.json')
    domain         = $config[:templates][:urn]
    templates_path = $config[:templates][:templates_path] ||= "templates"
    surname_prefix = "([Dd]e|V[ao]n)"
    output_dir     = 'imports'

    namespace :acquisitions do
      namespace :objects do
        config_file     = "#{templates_path}/collectionspace/acquisitions/objects.config.csv"
        template_file   = "#{templates_path}/collectionspace/acquisitions/object.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
        fields[:domain] = domain

        fields[:generate] = {
           objectPurchasePriceCurrencyId: {
            from: :objectPurchasePriceCurrency,
            required: false,
            unique: false,
            process: :get_currency_code,
          },
          acquisitionSourceId: {
            from: :acquisitionSource,
            required: false,
            unique: false,
            process: :get_short_identifier,
          },
          ownerId: {
            from: :owner,
            required: false,
            unique: false,
            process: :get_short_identifier,
          },
        }

        # rake template:cs:acquisitions:objects:fields
        desc "Display fields for acquisitions objects"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:acquisitions:objects:process[templates/collectionspace/acquisitions/objects.example.csv]
        desc "Create acquisitions XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "acquisitionReferenceNumber").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :cataloging do
      namespace :objects do
        config_file     = "#{templates_path}/collectionspace/cataloging/objects.config.csv"
        template_file   = "#{templates_path}/collectionspace/cataloging/object.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
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

        # rake template:cs:cataloging:objects:fields
        desc "Display fields for cataloging objects"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:cataloging:objects:process[templates/collectionspace/cataloging/objects.example.csv]
        desc "Create cataloging XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "id").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :conditioncheck do
      namespace :objects do
        config_file     = "#{templates_path}/collectionspace/conditioncheck/objects.config.csv"
        template_file   = "#{templates_path}/collectionspace/conditioncheck/object.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
        fields[:domain] = domain

        fields[:filter] = {
          # note: ->(value) { value.nil? or value.empty? },
        }

        # rake template:cs:conditioncheck:objects:fields
        desc "Display fields for conditioncheck objects"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:conditioncheck:objects:process[templates/collectionspace/conditioncheck/objects.example.csv]
        desc "Create conditioncheck XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "id").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :concepts do
      namespace :items do
        config_file     = "#{templates_path}/collectionspace/concepts/items.config.csv"
        template_file   = "#{templates_path}/collectionspace/concepts/item.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
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

        # rake template:cs:concepts:items:fields
        desc "Display fields for concept authority items"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:concepts:items:process[templates/collectionspace/concepts/items.example.csv]
        desc "Create concept authority item XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "shortidentifier").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :groups do
      namespace :objects do
        config_file     = "#{templates_path}/collectionspace/groups/objects.config.csv"
        template_file   = "#{templates_path}/collectionspace/groups/object.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
        fields[:domain] = domain

        # rake template:cs:groups:objects:fields
        desc "Display fields for groups"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:groups:objects:process[templates/collectionspace/groups/objects.example.csv]
        desc "Create group object XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "title").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :locations do
      namespace :authorities do
        # todo
        # rake template:cs:locations:authorities:process[templates/collectionspace/locations/authorities.example.csv]
      end

      namespace :items do
        config_file     = "#{templates_path}/collectionspace/locations/items.config.csv"
        template_file   = "#{templates_path}/collectionspace/locations/item.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
        fields[:domain] = domain

        fields[:generate] = {
          shortidentifier: {
            from: :termname,
            required: true,
            unique: true,
            process: :get_short_identifier,
          },
        }

        # rake template:cs:locations:items:fields
        desc "Display fields for location authority items"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:locations:items:process[templates/collectionspace/locations/onsite.csv]
        desc "Create location authority item XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "shortidentifier").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :loansout do
      namespace :objects do
        config_file     = "#{templates_path}/collectionspace/loansout/objects.config.csv"
        template_file   = "#{templates_path}/collectionspace/loansout/object.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
        fields[:domain] = domain

        fields[:generate] = {
          borrower_id: {
            from: :borrower,
            required: false,
            unique: false,
            process: :get_short_identifier,
          },
        }

        # rake template:cs:loansout:objects:fields
        desc "Display fields for loansout objects"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:loansout:objects:process[templates/collectionspace/loansout/objects.example.csv]
        desc "Create loansout XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "id").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :media do
      namespace :objects do
        config_file     = "#{templates_path}/collectionspace/media/objects.config.csv"
        template_file   = "#{templates_path}/collectionspace/media/object.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
        fields[:domain] = domain

        # rake template:cs:media:objects:fields
        desc "Display fields for media objects"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:media:objects:process[templates/collectionspace/media/objects.example.csv]
        desc "Create media XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "id").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :organizations do
      namespace :items do
        config_file     = "#{templates_path}/collectionspace/organizations/items.config.csv"
        template_file   = "#{templates_path}/collectionspace/organizations/item.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
        fields[:domain] = domain

        fields[:generate] = {
          shortidentifier: {
            from: :name,
            required: true,
            unique: true,
            process: :get_short_identifier,
          },
        }

        # rake template:cs:organizations:items:fields
        desc "Display fields for organization authority items"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:organizations:items:process[templates/collectionspace/organizations/items.example.csv]
        desc "Create organization authority item XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "shortidentifier").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :persons do
      namespace :items do
        config_file     = "#{templates_path}/collectionspace/persons/items.config.csv"
        template_file   = "#{templates_path}/collectionspace/persons/item.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
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

        # rake template:cs:persons:items:fields
        desc "Display fields for person authority items"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:persons:items:process[templates/collectionspace/persons/items.example.csv]
        desc "Create person authority item XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "shortidentifier").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :reports do
      namespace :objects do
        config_file     = "#{templates_path}/collectionspace/reports/objects.config.csv"
        template_file   = "#{templates_path}/collectionspace/reports/object.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
        fields[:domain] = domain

        # rake template:cs:reports:objects:fields
        desc "Display fields for reports objects"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:reports:objects:process[templates/collectionspace/reports/objects.example.csv]
        desc "Create reports XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "filename").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end

    namespace :valuationcontrol do
      namespace :objects do
        config_file     = "#{templates_path}/collectionspace/valuationcontrol/objects.config.csv"
        template_file   = "#{templates_path}/collectionspace/valuationcontrol/object.xml.erb"
        fields          = Csible::CSV.get_config(config_file)
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

        # rake template:cs:valuationcontrol:objects:fields
        desc "Display fields for valuationcontrol objects"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:cs:valuationcontrol:objects:process[templates/collectionspace/valuationcontrol/objects.example.csv]
        desc "Create valuationcontrol XML records from csv"
        task :process, [:csv, :output_dir, :filename_field] do |t, args|
          output_dir     = args[:output_dir] || output_dir
          filename_field = (args[:filename_field] || "id").to_sym
          processor = Csible::CSV::CollectionSpace.new(args[:csv], output_dir, template_file, fields)
          processor.process filename_field
        end
      end
    end
  end
end
