# TEMPLATES
namespace :template do
  desc "Process CollectionSpace XML template from CSV"

  output_dir = 'imports'

  namespace :locationauthorities do
    template_file = 'templates/locations/item.xml.erb'

    # todo: process *_fields from config file?
    required_fields = [
      "shortidentifier",
      "termname",
      "locationtype",
    ]

    optional_fields = [
      "address",
      "accessnote",
      "conditionnote",
      "securitynote",
    ]

    filename_fields = [ "shortidentifier" ]

    # rake template:locationauthorities:fields
    task :fields do |t|
      print_fields required_fields, optional_fields
    end

    # rake template:locationauthorities:process[templates/locations/onsite.csv]
    task :process, [:csv] do |t, args|
      process_csv(args[:csv], output_dir, template_file, required_fields, filename_fields)
    end

  end
end