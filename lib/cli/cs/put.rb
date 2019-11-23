namespace :cs do
  namespace :put do
    # rake cs:put:directory[acquisitions,imports]
    desc 'PUT requests by path using directory of files with csid filenames to import'
    task :directory, [:path, :directory] do |_t, args|
      path      = args[:path]
      directory = args[:directory]

      raise 'Invalid directory' unless File.directory? directory

      Dir["#{args[:directory]}/*.xml"].each do |file|
        # parse filename to get csid
        filename = File.basename(file, '.*')
        dest     = "#{path}/#{filename}"

        Rake::Task['cs:put:file'].invoke(dest, file)
        Rake::Task['cs:put:file'].reenable
      end
    end

    # rake cs:put:file[locationauthorities/XYZ/items/ABC,examples/locations/1.xml]
    desc 'PUT request by path with file of updated metadata'
    task :file, [:path, :file] do |_t, args|
      path = args[:path]
      file = args[:file]
      raise 'Invalid file' unless File.file? file

      payload = File.read(file)
      put     = Csible::HTTP::Put.new(CLIENT, LOG)
      begin
        put.execute path, payload
        File.unlink file
      rescue StandardError => err
        LOG.error err.message
      end
    end

    namespace :images do
      # rake cs:put:images:fuzzy[images.txt]
      # desc "PUT to create blobs for media from file of urls if image filename unambiguously matches record title"
      task :fuzzy, [:file, :throttle] do |_t, args|
        file      = args[:file]
        throttle  = args[:throttle] || 0.10
        raise 'Invalid input file' unless File.file? file

        File.open(file).each_line do |line|
          begin
            uri      = URI.parse(line.chomp)
            filename = File.basename(uri.path).tr('-', '*')
            get      = Csible::HTTP::Get.new(CLIENT, LOG)
            csid     = get.csid_for 'media', 'title', filename, true
            xml      = get.execute("media/#{csid}").xml.to_s

            put = Csible::HTTP::Put.new(CLIENT, LOG)
            put.execute "media/#{csid}?blobUri=#{uri}", xml
            sleep throttle
          rescue StandardError => err
            LOG.error err.message
          end
        end
      end
    end
  end
end
