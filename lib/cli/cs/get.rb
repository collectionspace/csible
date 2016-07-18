namespace :cs do

  namespace :get do

    # rake cs:get:path[locationauthorities]
    desc "GET request by path"
    task :path, [:path, :format, :params] do |t, args|
      path   = args[:path]
      format = (args[:format] || 'json').to_sym
      params = Csible::HTTP.convert_params(args[:params]  || '')
      get    = Csible::HTTP::Get.new($client, $log)
      begin
        get.execute :path, path, params
        get.print format
      rescue Exception => ex
        $log.error ex.message
      end
    end

    # rake cs:get:url[https://cspace.lyrasistechnology.org/cspace-services/locationauthorities]
    desc "GET request by url"
    task :url, [:url, :format, :params] do |t, args|
      url    = args[:url]
      format = (args[:format] || 'json').to_sym
      params = Csible::HTTP.convert_params(args[:params]  || '')
      get    = Csible::HTTP::Get.new($client, $log)
      begin
        get.execute :url, url, params
        get.print format
      rescue Exception => ex
        $log.error ex.message
      end

    end

    # rake cs:get:list[media,"wf_deleted=false&pgSz=100"]
    desc "GET request by path for results list to csv specifying properties"
    task :list, [:path, :params, :output] do |t, args|
      path       = args[:path]
      params     = Csible::HTTP.convert_params(args[:params]  || '')
      output     = args[:output] || "response.csv"
      get        = Csible::HTTP::Get.new($client, $log)
      results    = get.list path, params
      File.open(output, "w")
      Csible.write_csv(output, results, $log) unless results.empty?
    end

  end

end