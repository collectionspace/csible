# TEMPLATES
namespace :template do
  namespace :pp do

    $config        = Csible.get_config('api.json')
    output_dir     = 'transforms'
    templates_path = $config[:templates][:templates_path] ||= "templates"

    namespace :accessions do
      config_file     = "#{templates_path}/pastperfect/accessions/accessions.config.csv"
      mapping_file    = "#{templates_path}/pastperfect/accessions/accessions.map.csv"
      fields          = Csible::CSV.get_config(config_file)

      fields[:generate] = {
        ownertype: {
          from: :accessno,
          required: false,
          unique: false,
          process: ->(value) { 'person' }
        },
      }

      fields[:merge] = {
        descrip_: :notes_,
      }

      fields[:transforms] = {
        accby: ->(value) { value.gsub(/^\W/, "").gsub(/\;/, " and ").squeeze(" ").strip },
        accdate: ->(value) { value.gsub(/^(\s*)-(\s*)-/, "") },
        recby: ->(value) { value.gsub(/^\W/, "").gsub(/\;/, " and ").squeeze(" ").strip },
        recfrom: ->(value) { value.gsub(/^\W/, "").gsub(/\;/, " and ").squeeze(" ").strip },
      }

      # rake template:pp:accessions:fields
      desc "Display fields for accessions objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:pp:accessions:process[templates/pastperfect/accessions/accessions.example.csv]
      desc "Create CollectionSpace accessions CSV from Past Perfect csv"
      task :process, [:csv, :output_dir] do |t, args|
        output_dir = args[:output_dir] || output_dir
        processor = Csible::CSV::PastPerfect.new(args[:csv], output_dir, mapping_file, fields)
        processor.process
      end
    end

    namespace :objects do
      config_file     = "#{templates_path}/pastperfect/objects/objects.config.csv"
      mapping_file    = "#{templates_path}/pastperfect/objects/objects.map.csv"
      fields          = Csible::CSV.get_config(config_file)

      fields[:generate] = {
        ownertype: {
          from: :objectid,
          required: false,
          unique: false,
          process: ->(value) { 'person' }
        },
        conditioncheckid: {
          from: :objectid,
          required: true,
          unique: false,
          process: ->(value) { value }
        },
        loaninid: {
          from: :objectid,
          required: true,
          unique: false,
          process: ->(value) { value }
        },
        valuationid: {
          from: :objectid,
          required: true,
          unique: false,
          process: ->(value) { value }
        },
      }

      # rake template:pp:objects:fields
      desc "Display fields for objects objects"
      task :fields do |t|
        Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
      end

      # rake template:pp:objects:process[templates/pastperfect/objects/objects.example.csv]
      desc "Create CollectionSpace collectionobjects CSV from Past Perfect csv"
      task :process, [:csv, :output_dir] do |t, args|
        output_dir = args[:output_dir] || output_dir
        processor = Csible::CSV::PastPerfect.new(args[:csv], output_dir, mapping_file, fields)
        processor.process
      end
    end
  end
end
