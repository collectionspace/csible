require_relative 'cs/delete'
require_relative 'cs/get'
require_relative 'cs/post'
require_relative 'cs/put'
require_relative 'cs/relate'
require_relative 'cs/update'

namespace :cs do
  # rake cs:cache[collectionobjects.csv,objectNumber,csid]
  # rake cs:cache[media.csv,identificationNumber,csid]
  desc 'Add key value pairs to redis from csv'
  task :cache, [:csv, :key_column, :value_column] do |_t, args|
    redis        = Redis.new # fail if redis unavailable
    csv          = args[:csv]
    key_column   = args[:key_column]
    value_column = args[:value_column]

    CSV.foreach(csv,
                headers: true) do |row|
      data = row.to_hash
      key  = data[key_column]
      val  = data[value_column]
      unless key && val
        raise "Invalid csv: data not found for #{key_column}, #{value_column}"
      end

      redis.set(key, val)
    end
  end

  # rake cs:config
  desc 'Dump csible config to terminal'
  task :config do |_t, _args|
    ap CONFIG
  end

  # rake cs:initialize[core]
  desc 'Initialize authorities for tenant'
  task :initialize, [:tenant] do |_t, args|
    tenant = args[:tenant] || 'core'
    path   = "collectionspace/tenant/#{tenant}/authorities/initialise"
    url    = CONFIG[:services][:base_uri].gsub('cspace-services', path)
    req    = Csible::HTTP::Request.new(CLIENT, LOG)
    begin
      req.do_raw :get, url, {}
    rescue StandardError => err
      LOG.error err.message
    end
  end

  # rake cs:parse_xml["relation-list-item > uri"]
  desc 'Parse xml for element value'
  task :parse_xml, [:element, :input, :output] do |_t, args|
    element = args[:element]
    input   = args[:input] || 'response.xml'
    output  = args[:output] || 'response.txt'
    raise 'HELL' unless File.file?(input) && File.file?(output)

    result = Csible.get_element_values(input, element)
    Csible.write_file output, result.join("\n", LOG)
  end
end
