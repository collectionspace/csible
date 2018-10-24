# TEMPLATES
namespace :template do
  namespace :cs do

    $config        = Csible.get_config('api.json')
    domain         = $config[:templates][:urn]
    templates_path = $config[:templates][:templates_path] ||= "templates"
    surname_prefix = "([Dd]e|V[ao]n)"
    output_dir     = 'imports'

    namespace :acquisitions do
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
        acquisitionSource1Id: {
          from: :acquisitionSource1,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        acquisitionSource2Id: {
          from: :acquisitionSource2,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        acquisitionAuthorizerId: {
          from: :acquisitionAuthorizer,
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

      # rake template:cs:acquisitions:fields
      desc "Display fields for acquisitions objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:acquisitions:process[templates/collectionspace/acquisitions/objects.example.csv]
      desc "Create acquisitions XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "acquisitionReferenceNumber").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :cataloging do
      config_file     = "#{templates_path}/collectionspace/cataloging/objects.config.csv"
      template_file   = "#{templates_path}/collectionspace/cataloging/object.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        assocPersonId: {
          from: :assocPerson,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        contentConcept1Id: {
          from: :contentConcept1,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        contentConcept2Id: {
          from: :contentConcept2,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        objectProductionPerson1Id: {
          from: :objectProductionPerson1,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        objectProductionPerson2Id: {
          from: :objectProductionPerson2,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
        objectProductionPlace1Id: {
          from: :objectProductionPlace1,
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
        taxonId: {
          from: :taxon,
          required: false,
          unique: false,
          process: :get_short_identifier,
        }
      }

      fields[:transforms] = {
        collection:      ->(value) { value.downcase },
        contentConcept1: ->(value) { value.capitalize },
        contentConcept2: ->(value) { value.capitalize },
        objectProductionDatePeriod: ->(value) { value.capitalize },
        # objectProductionPlaces: -> (value) { value.gsub(/\s/,'').split(",").map(&:capitalize).join(", ") },
        title: ->(value) { value.capitalize },
      }

      # rake template:cs:cataloging:fields
      desc "Display fields for cataloging objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:cataloging:process[templates/collectionspace/cataloging/objects.example.csv]
      desc "Create cataloging XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "objectNumber").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :conditioncheck do
      config_file     = "#{templates_path}/collectionspace/conditioncheck/objects.config.csv"
      template_file   = "#{templates_path}/collectionspace/conditioncheck/object.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      fields[:filter] = {
        # note: ->(value) { value.nil? or value.empty? },
      }

      # rake template:cs:conditioncheck:fields
      desc "Display fields for conditioncheck objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:conditioncheck:process[templates/collectionspace/conditioncheck/objects.example.csv]
      desc "Create conditioncheck XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "conditionCheckRefNumber").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :concepts do
      config_file     = "#{templates_path}/collectionspace/concepts/items.config.csv"
      template_file   = "#{templates_path}/collectionspace/concepts/item.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        shortIdentifier: {
          from: :termDisplayName,
          required: true,
          unique: true,
          process: :get_short_identifier,
        },
      }

      fields[:transforms] = {
        termDisplayName: ->(value) { value.capitalize },
      }

      # rake template:cs:concepts:fields
      desc "Display fields for concept authority items"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:concepts:process[templates/collectionspace/concepts/items.example.csv]
      desc "Create concept authority item XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "shortIdentifier").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :groups do
      config_file     = "#{templates_path}/collectionspace/groups/objects.config.csv"
      template_file   = "#{templates_path}/collectionspace/groups/object.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      # rake template:cs:groups:fields
      desc "Display fields for groups"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:groups:process[templates/collectionspace/groups/objects.example.csv]
      desc "Create group object XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "title").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :locations do
      namespace :authorities do
        # todo
        # rake template:cs:locations:authorities:process[templates/collectionspace/locations/authorities.example.csv]
      end

      config_file     = "#{templates_path}/collectionspace/locations/items.config.csv"
      template_file   = "#{templates_path}/collectionspace/locations/item.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        shortIdentifier: {
          from: :termdisplayname,
          required: true,
          unique: true,
          process: :get_short_identifier,
        },
      }

      # rake template:cs:locations:fields
      desc "Display fields for location authority items"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:locations:process[templates/collectionspace/locations/items.example.csv]
      desc "Create location authority item XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "shortIdentifier").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :loansin do
      config_file     = "#{templates_path}/collectionspace/loansin/objects.config.csv"
      template_file   = "#{templates_path}/collectionspace/loansin/object.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      # rake template:cs:loansin:fields
      desc "Display fields for loansin objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:loansin:process[templates/collectionspace/loansin/objects.example.csv]
      desc "Create loansin XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "loanInNumber").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :loansout do
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

      # rake template:cs:loansout:fields
      desc "Display fields for loansout objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:loansout:process[templates/collectionspace/loansout/objects.example.csv]
      desc "Create loansout XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "id").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :media do
      config_file     = "#{templates_path}/collectionspace/media/objects.config.csv"
      template_file   = "#{templates_path}/collectionspace/media/object.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      # rake template:cs:media:fields
      desc "Display fields for media objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:media:process[templates/collectionspace/media/objects.example.csv]
      desc "Create media XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "id").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :organizations do
      config_file     = "#{templates_path}/collectionspace/organizations/items.config.csv"
      template_file   = "#{templates_path}/collectionspace/organizations/item.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        shortIdentifier: {
          from: :termDisplayName,
          required: true,
          unique: true,
          process: :get_short_identifier,
        },
      }

      # rake template:cs:organizations:fields
      desc "Display fields for organization authority items"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:organizations:process[templates/collectionspace/organizations/items.example.csv]
      desc "Create organization authority item XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "shortIdentifier").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :persons do
      config_file     = "#{templates_path}/collectionspace/persons/items.config.csv"
      template_file   = "#{templates_path}/collectionspace/persons/item.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        shortIdentifier: {
          from: :termDisplayName,
          required: true,
          unique: true,
          process: :get_short_identifier,
        },
        foreName: {
          from: :termDisplayName,
          required: false,
          unique: false,
          process: ->(value) {
            name  = ""
            if value =~ /,/
              name = value.split(",")[1].split(" ")[0]
            else
              names = value.split(" ")
              name  = names[0] if names.length > 1
            end
            name
          },
        },
        middleName: {
          from: :termDisplayName,
          required: false,
          unique: false,
          process: ->(value) {
            name  = ""
            if value =~ /,/
              names = value.split(",")[1]
              parts = names.split(" ")
              name  = parts[1] if parts.length > 1
            else
              names = value.split(" ")
              if names.length > 2
                first, middle, last = names
                name = middle unless middle =~ /^#{surname_prefix}/
              end
            end
            name
          },
        },
        surName: {
          from: :termDisplayName,
          required: false,
          unique: false,
          process: ->(value) {
            name  = ""
            if value =~ /,/
              name = value.split(",")[0]
            else
              names = value.split(" ")
              name  = names[-1] if names.length >= 2
              name  = "#{names[1]} #{name}" if names[1] =~ /^#{surname_prefix}/
            end
            name
          },
        },
      }

      # rake template:cs:persons:fields
      desc "Display fields for person authority items"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:persons:process[templates/collectionspace/persons/items.example.csv]
      desc "Create person authority item XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "shortIdentifier").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :reports do
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
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :batch do
      config_file     = "#{templates_path}/collectionspace/batch/objects.config.csv"
      template_file   = "#{templates_path}/collectionspace/batch/object.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      # rake template:cs:batch:objects:fields
      desc "Display fields for batch objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:batch:objects:process[templates/collectionspace/batch/objects.example.csv]
      desc "Create batch XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "name").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :batch_invoke do
      config_file     = "#{templates_path}/collectionspace/batch_invoke/objects.config.csv"
      template_file   = "#{templates_path}/collectionspace/batch_invoke/object.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      # rake template:cs:batch_invoke:objects:fields
      desc "Display fields for batch_invoke objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:batch_invoke:objects:process[templates/collectionspace/batch_invoke/objects.example.csv]
      desc "Create batch_invoke XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "singleCSID").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :valuationcontrol do
      config_file     = "#{templates_path}/collectionspace/valuationcontrol/objects.config.csv"
      template_file   = "#{templates_path}/collectionspace/valuationcontrol/object.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      fields[:filter] = {
        # value: ->(value) { value.nil? or value.empty? },
      }

      fields[:generate] = {
        valueCurrencyId: {
          from: :valueCurrency,
          required: false,
          unique: false,
          process: :get_currency_code,
        },
        valueSourceId: {
          from: :valueSource,
          required: false,
          unique: false,
          process: :get_short_identifier,
        },
      }

      # rake template:cs:valuationcontrol:fields
      desc "Display fields for valuationcontrol objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:valuationcontrol:process[templates/collectionspace/valuationcontrol/objects.example.csv]
      desc "Create valuationcontrol XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "valuationcontrolRefNumber").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :update do
      config_file     = "#{templates_path}/collectionspace/updates/update.config.csv"
      template_file   = "#{templates_path}/collectionspace/updates/update.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      # rake template:cs:update:fields
      desc "Display fields for vocabulary items"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:update:process[templates/collectionspace/updates/update.example.csv]
      desc "Create vocabulary item XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "csid").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

    namespace :vocabulary do
      config_file     = "#{templates_path}/collectionspace/vocabulary/items.config.csv"
      template_file   = "#{templates_path}/collectionspace/vocabulary/item.xml.erb"
      fields          = Csible::CSV.get_config(config_file)
      fields[:domain] = domain

      fields[:generate] = {
        shortIdentifier: {
          from: :displayName,
          required: true,
          unique: true,
          process: :get_vocab_identifier,
        }
      }

      # rake template:cs:vocabulary:fields
      desc "Display fields for vocabulary items"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:cs:vocabulary:process[templates/collectionspace/vocabulary/items.example.csv]
      desc "Create vocabulary item XML records from csv"
      task :process, [:csv, :output_dir, :filename_field] do |t, args|
        output_dir     = args[:output_dir] || output_dir
        filename_field = (args[:filename_field] || "shortIdentifier").to_sym
        processor = Csible::CSV::ToCollectionSpace.new(args[:csv], output_dir, template_file, fields)
        processor.process filename_field
      end
    end

  end # end cs namespace
end
