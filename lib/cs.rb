# helpers

# ansible playbook command wrapper
def command(base, method, opts = {})
  command = base + " --extra-vars='method=#{method}"
  opts.each do |arg, value|
    command = "#{command} #{arg.to_s}=#{value}" if value
  end
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
      sh command(base_command, 'GET', { path: path, params: params })
    end

    # rake cs:get:url[https://cspace.lyrasistechnology.org/cspace-services/locationauthorities]
    task :url, [:url] do |t, args|
      url    = args[:url]
      sh command(base_command, 'GET', { url: url })
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
      path = args[:path]
      file = args[:file]
      raise "Invalid file" unless File.file? file
      sh command(base_command, 'POST', { path: path, file: file })
    end

  end

  namespace :delete do

    task :path, [:path] do |t, args|
      path = args[:path]
      sh command(base_command, 'DELETE', { path: path })
    end

    task :url, [:url] do |t, args|
      url = args[:url]
      url = url.gsub(/http:/, 'https:') # always https
      sh command(base_command, 'DELETE', { url: url })
    end

    # rake cs:delete:file[deletes.txt]
    # rake cs:delete:file[deletes.txt,path,1]
    task :file, [:file, :type, :throttle] do |t, args|
      file      = args[:file]
      type      = args[:type] || "url"
      throttle  = args[:throttle] || 1
      raise "HELL" unless File.file? file
      File.readlines(file).each do |line|
        Rake::Task["cs:delete:#{type}"].invoke(line)
        sh "sleep #{throttle}"
        Rake::Task["cs:delete:#{type}"].reenable
      end
    end

  end

end