# TEMPLATES
namespace :template do

  output_dir = 'imports'

  namespace :locations do
    namespace :authorities do
      # todo
      # rake template:locations:authorities:process[templates/locations/authorities.example.csv]
    end

    namespace :items do
      config_file   = 'templates/locations/items.config.csv'
      template_file = 'templates/locations/item.xml.erb'
      fields        = get_config(config_file)

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