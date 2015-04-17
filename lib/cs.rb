# helpers

# ansible playbook command wrapper
# type is one of = path, file, directory, url
def command(base, method, type, arg, params = nil)
  command = base + " --extra-vars='method=#{method} #{type}=#{arg}"
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

  namespace :get do

    # rake cs:get:path[/locationauthorities]
    task :path, [:path, :params] do |t, args|
      path   = args[:path]
      params = args[:params] || nil

      sh command(base_command, 'GET', 'path', path, params)
    end

    # rake cs:get:url[https://cspace.lyrasistechnology.org/cspace-services/locationauthorities]
    task :url, [:url, :params] do |t, args|
      url    = args[:url]
      params = args[:params] || nil

      sh command(base_command, 'GET', 'url', url, params)
    end

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

    # rake cs:post:file[/locationauthorities/XYZ/items,examples/locations/1.xml]
    task :file, [:path, :file] do |t, args|
      file = args[:file]
      raise "Invalid file" unless File.file? file
      puts file
      # sh "ansible-playbook -i ..."
    end

  end

  namespace :delete do

    task :path, [:path] do |t, args|
      path = args[:path]
      sh command(base_command, 'DELETE', 'path', path)
    end

    task :url, [:url] do |t, args|
      url = args[:url]
      sh command(base_command, 'DELETE', 'url', url)
    end

    # rake cs:delete:file[deletes.txt]
    task :file, [:file] do |t, args|
      file = args[:file]
      raise "HELL" unless File.file? file
      sh command(base_command, 'DELETE', 'file', file)
    end

  end

end