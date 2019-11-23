namespace :cs do
  namespace :get do
    # rake cs:get:path[locationauthorities]
    desc 'GET request by path'
    task :path, [:path, :format, :params] do |_t, args|
      path   = args[:path]
      format = (args[:format] || 'json').to_sym
      params = Csible::HTTP.convert_params(args[:params] || '')
      get    = Csible::HTTP::Get.new(CLIENT, LOG)
      begin
        get.execute path, params
        get.print format
      rescue StandardError => err
        LOG.error err.message
      end
    end

    # rake cs:get:list[media,"wf_deleted=false&pgSz=100"]
    desc 'GET request by path for results list to csv specifying properties'
    task :list, [:path, :params, :output] do |_t, args|
      path       = args[:path]
      params     = Csible::HTTP.convert_params(args[:params] || '')
      output     = args[:output] || 'response.csv'
      message    = "List output for #{path} was written to #{output}"
      get        = Csible::HTTP::Get.new(CLIENT, LOG)

      Csible.clear_file output
      FileUtils.touch output
      get.list path, output, params
      LOG.info message
      puts message
    end
  end
end
