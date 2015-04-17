# helpers
def get_command(base, path, params = nil)
    command = base + " --extra-vars='path=#{path}"
    command = "#{command} params=#{params}" if params
    command = "#{command}'"
    command
end

namespace :cs do
  desc "Run csible commands"

  base_command = "ansible-playbook -i 'localhost,' services.yml --extra-vars='@api.json'"

  # rake cs:config
  task :config do |t, args|
    pp JSON.parse( IO.read('api.json') )
  end

  # rake cs:get[/locationauthorities]
  task :get, [:path, :params] do |t, args|
    path   = args[:path]
    params = args[:params] || nil

    sh get_command(base_command, path, params)
  end

  namespace :post do

    # rake cs:post:directory[/locationauthorities/XYZ/items,examples/locations,1]
    task :directory, [:path, :directory, :throttle] do |t, args|
      path      = args[:path]
      directory = args[:directory]
      throttle  = args[:throttle] || 1

      raise "Invalid directory" unless File.directory? directory

      Dir["#{args[:directory]}/*.xml"].each do |file|
        Rake::Task["cs:post:file"].invoke(path, file)
        sh "sleep #{throttle}"
        Rake::Task["cs:post:file"].reenable
      end
    end

    # rake cs:post:directory[/locationauthorities/XYZ/items,examples/locations/1.xml]
    task :file, [:path, :file] do |t, args|
      file = args[:file]
      raise "Invalid file" unless File.file? file
      puts file
      # sh "ansible-playbook -i ..."
    end

  end

end