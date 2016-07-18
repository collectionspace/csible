namespace :cs do

  namespace :put do

    # rake cs:put:file[locationauthorities/XYZ/items/ABC,examples/locations/1.xml]
    desc "PUT request by path with file of updated metadata"
    task :file, [:path, :file] do |t, args|
      path = args[:path]
      file = args[:file]
      raise "Invalid file" unless File.file? file
      payload = File.read(file)
      put     = Csible::HTTP::Put.new($client, $log)
      begin
        put.execute :path, path, payload
        File.unlink file
      rescue Exception => ex
        $log.error ex.message
      end
    end

  end

end