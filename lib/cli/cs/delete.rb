namespace :cs do

  namespace :delete do

    desc "DELETE request by path"
    task :path, [:path] do |t, args|
      path   = args[:path]
      delete = Csible::HTTP::Delete.new($client, $log)
      begin
        delete.execute :path, path
      rescue Exception => ex
        $log.error ex.message
      end
    end

    desc "DELETE request by url"
    task :url, [:url] do |t, args|
      url      = args[:url]
      protocol = URI.parse( $client.config.base_uri ).scheme
      url      = url.gsub(/https?:/, "#{protocol}:") if protocol !~ /#{url}/
      delete   = Csible::HTTP::Delete.new($client, $log)
      begin
        delete.execute :url, url
      rescue Exception => ex
        $log.error ex.message
      end
    end

    # rake cs:delete:file[deletes.txt]
    # rake cs:delete:file[deletes.txt,path]
    desc "DELETE requests by file of urls or paths"
    task :file, [:file, :type, :throttle] do |t, args|
      file      = args[:file]
      type      = args[:type] || "url"
      raise "HELL" unless File.file? file
      File.readlines(file).each do |line|
        Rake::Task["cs:delete:#{type}"].invoke(line)
        Rake::Task["cs:delete:#{type}"].reenable
      end
    end

  end

end