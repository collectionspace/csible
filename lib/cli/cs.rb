require_relative "cs/delete"
require_relative "cs/get"
require_relative "cs/post"
require_relative "cs/put"
require_relative "cs/relate"
require_relative "cs/update"

namespace :cs do
  # rake cs:cache[response.csv]
  desc "Add key value pairs to redis from csv"
  task :cache, [:csv] do |t, args|
    redis = Redis.new # fail if redis unavailable
    csv   = args[:csv]
    CSV.foreach(csv, {
        headers: true,
        header_converters: ->(header) { header.to_sym },
      }) do |row|
      key, value = row.to_hash.values
      raise "Invalid csv values #{key} #{value}" if key.empty? or value.empty?
      redis.set(key, value)
    end
  end

  # rake cs:config
  desc "Dump csible config to terminal"
  task :config do |t, args|
    ap $config
  end

  # rake cs:initialize[core]
  desc "Initialize authorities for tenant"
  task :initialize do |t, args|
    tenant = args[:tenant] || 'core'
    path   = "collectionspace/tenant/#{tenant}/authorities/initialise"
    url    = $config[:services][:base_uri].gsub("cspace-services", path)
    req    = Csible::HTTP::Request.new($client, $log)
    begin
      req.do_raw :get, url, {}
    rescue Exception => ex
      $log.error ex.message
    end
  end

  # rake cs:parse_xml["relation-list-item > uri"]
  desc "Parse xml for element value"
  task :parse_xml, [:element, :input, :output] do |t, args|
    element = args[:element]
    input   = args[:input] || "response.xml"
    output  = args[:output] || "response.txt"
    raise "HELL" unless File.file? input and File.file? output
    result  = Csible.get_element_values(input, element)
    Csible.write_file output, result.join("\n", $log)
  end

end
