# TEMPLATES
namespace :template do
  namespace :pp do

    $config        = Csible.get_config('api.json')
    output_dir     = 'transforms'
    templates_path = $config[:templates][:templates_path] ||= "templates"

    namespace :accessions do
      namespace :objects do
        config_file     = "#{templates_path}/pastperfect/accessions/objects.config.csv"
        mapping_file    = "#{templates_path}/pastperfect/accessions/objects.map.csv"
        fields          = Csible::CSV.get_config(config_file)

        # rake template:pp:accessions:objects:fields
        desc "Display fields for accessions objects"
        task :fields do |t|
          Csible::CSV.print_fields fields[:required], fields[:optional], fields[:generate].keys
        end

        # rake template:pp:accessions:objects:process[templates/pastperfect/accessions/objects.example.csv]
        desc "Create CollectionSpace accessions CSV from Past Perfect csv"
        task :process, [:csv, :output_dir] do |t, args|
          output_dir = args[:output_dir] || output_dir
          processor = Csible::CSV::PastPerfect.new(args[:csv], output_dir, mapping_file, fields)
          processor.process
        end
      end
    end
  end
end
