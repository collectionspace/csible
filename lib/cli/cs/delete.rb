namespace :cs do
  namespace :delete do
    desc 'DELETE request by path'
    task :path, [:path] do |_t, args|
      path   = args[:path]
      delete = Csible::HTTP::Delete.new(CLIENT, LOG)
      begin
        delete.execute path
      rescue StandardError => err
        LOG.error err.message
      end
    end

    # rake cs:delete:file[deletes.txt]
    # rake cs:delete:file[deletes.txt,path]
    desc 'DELETE requests by file of urls or paths'
    task :file, [:file, :type, :throttle] do |_t, args|
      file      = args[:file]
      type      = args[:type] || 'url'
      raise 'HELL' unless File.file? file

      File.readlines(file).each do |line|
        line = line.chomp
        Rake::Task["cs:delete:#{type}"].invoke(line)
        Rake::Task["cs:delete:#{type}"].reenable
      end
    end
  end
end
