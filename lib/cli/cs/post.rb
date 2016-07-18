namespace :cs do

  namespace :post do

    # rake cs:post:directory[locationauthorities/XYZ/items,examples/locations]
    desc "POST requests by path using directory of files to import"
    task :directory, [:path, :directory] do |t, args|
      path      = args[:path]
      directory = args[:directory]

      raise "Invalid directory" unless File.directory? directory

      Dir["#{args[:directory]}/*.xml"].each do |file|
        Rake::Task["cs:post:file"].invoke(path, file)
        Rake::Task["cs:post:file"].reenable
      end
    end

    # rake cs:post:file[locationauthorities/XYZ/items,examples/locations/1.xml]
    desc "POST request by path using file to import"
    task :file, [:path, :file] do |t, args|
      path = args[:path]
      file = args[:file]
      raise "Invalid file" unless File.file? file
      payload = File.read(file)
      post    = Csible::HTTP::Post.new($client, $log)
      begin
        post.execute :path, path, payload
        File.unlink file
      rescue Exception => ex
        $log.error ex.message
      end
    end

  end

end