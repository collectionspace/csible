# TEMPLATES
namespace :template do
  namespace :pp do

    $config        = Csible.get_config('api.json')
    output_dir     = 'transforms'
    templates_path = $config[:templates][:templates_path] ||= "templates"

    namespace :accessions do
      config_file     = "#{templates_path}/pastperfect/accessions/accessions.map.csv"
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
        processor = Csible::CSV::ToCSV.new(args[:csv], output_dir, mapping_file, fields)
        processor.process
      end
    end

    namespace :objects do
      config_file     = "#{templates_path}/pastperfect/objects/objects.map.csv"
      mapping_file    = "#{templates_path}/pastperfect/objects/objects.map.csv"
      fields          = Csible::CSV.get_config(config_file)

      fields[:generate] = {
        appraisortype: {
          from: :objectid,
          required: false,
          unique: false,
          process: ->(value) { 'organization' }
        },
        ownertype: {
          from: :objectid,
          required: false,
          unique: false,
          process: ->(value) { 'person' }
        },
        # added to cataloging csv for easy relationship processing
        acqid: {
          from: :accessno,
          required: false,
          unique: false,
          process: ->(value) { value.nil? ? "" : value }
        },
        # TODO: determine whether to use loanInNumber as is or generate and use note
        liid: {
          from: :loanInNumber,
          required: false,
          unique: false,
          process: ->(value) { value.nil? ? "" : value }
        },
        # added to cataloging csv for easy relationship processing
        ccid: {
          from: :objectid,
          required: true,
          unique: false,
          process: ->(value) { "CC#{value}" }
        },
        # for conditionchecks procedure csv (matches ccid)
        conditioncheckid: {
          from: :objectid,
          required: true,
          unique: false,
          process: ->(value) { "CC#{value}" }
        },
        # added to cataloging csv for easy relationship processing
        vcid: {
          from: :objectid,
          required: true,
          unique: false,
          process: ->(value) { "VC#{value}" }
        },
        # for valuationcontrol procedure csv (matches vcid)
        valuationid: {
          from: :objectid,
          required: true,
          unique: false,
          process: ->(value) { "VC#{value}" }
        },
        # added to cataloging csv to reference storage locations (see permloc)
        loc: {
          from: :permloc,
          required: false,
          unique: false,
          process: ->(value) { value }
        }
      }

      fields[:transforms] = {
        width: -> (value) { "#{value},centimeters" },
        length: -> (value) { "#{value},centimeters" },
        height: -> (value) { "#{value},centimeters" },
        depth: -> (value) { "#{value},centimeters" },
        diameter: -> (value) { "#{value},centimeters" },
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
        processor = Csible::CSV::ToCSV.new(args[:csv], output_dir, mapping_file, fields)
        processor.process
      end
    end
  end
end
