module Csible

  def self.convert_params(param_string)
    Hash[CGI.parse(param_string).map {|key,values| [key.to_sym, values[0]||true]}]
  end

  def self.get_client(config)
    CollectionSpace::Client.new(CollectionSpace::Configuration.new(config))
  end

  def self.get_config(path)
    JSON.parse( IO.read(path), symbolize_names: true )
  end

  def self.write_csv(filename, data, log = Logger.new(STDOUT))
    CSV.open(filename, 'w') do |csv|
      csv << data.first.keys
      data.each { |row| csv << row.values }
    end
  end

  def self.write_file(filename, data, log = Logger.new(STDOUT))
    File.open(filename, 'w') {|f| f.write(data) }
    log.info "Created #{filename}"
  end

  module Helpers

    def check_status!
      raise "ERROR [#{self.class.to_s.upcase}] #{result.status_code.to_s} #{@result.status.inspect}" unless @result.status_code.to_s =~ /^2/
    end

    def print(format = :parsed)
      if format == :xml
        puts @result.xml.to_xml
      else
        ap @result.parsed
      end
    end

  end

  class Request

    attr_reader :client, :log, :result

    def initialize(client, log = Logger.new(STDOUT))
      @client = client
      @log    = log
      @result = nil
    end

  end


  class Get < Request
    include Helpers

    def execute(type, resource, params = {})
      if type == :path
        @result = client.get resource, { query: params }
      elsif type == :url
        username = client.config.username
        password = client.config.password
        @result = HTTParty.get resource, { basic_auth: { username: username, password: password }, query: params }
        @result = CollectionSpace::Response.new result # wrap the response
      else
        raise "Unrecognized request type: #{type}"
      end

      check_status!
      log.info "GET #{result.status_code.to_s} #{result.status.inspect}"
      result
    end

    def list(path, params = {})
      list = []
      client.all(path, params) do |record|
        list << record
        log.info "LIST [#{record["uri"]}]"
      end
      list
    end

  end

  class Post < Request
    include Helpers

    def execute(type, resource, payload)
      raise "Payload error" unless payload
      if type == :path
        @result = client.post resource, payload
      elsif type == :url
        username = client.config.username
        password = client.config.password
        @result = HTTParty.post resource, { basic_auth: { username: username, password: password }, body: payload }
        @result = CollectionSpace::Response.new result # wrap the response
      else
        raise "Unrecognized request type: #{type}"
      end
      check_status!
      log.info "POST #{result.status_code.to_s} #{result.status.inspect}"
      result
    end

  end

  class Put < Request
    include Helpers

    def execute(type, resource, payload)
      raise "Payload error" unless payload
      if type == :path
        @result = client.put resource, payload
      elsif type == :url
        username = client.config.username
        password = client.config.password
        @result = HTTParty.put method, resource, { basic_auth: { username: username, password: password }, body: payload }
        @result = CollectionSpace::Response.new result # wrap the response
      else
        raise "Unrecognized request type: #{type}"
      end
      check_status!
      log.info "PUT #{result.status_code.to_s} #{result.status.inspect}"
      result
    end

  end

  class Delete < Request
    include Helpers

    def execute(type, resource)
      if type == :path
        @result = client.delete resource
      elsif type == :url
        username = client.config.username
        password = client.config.password
        @result = HTTParty.delete resource, { basic_auth: { username: username, password: password } }
        @result = CollectionSpace::Response.new result # wrap the response
      else
        raise "Unrecognized request type: #{type}"
      end
      check_status!
      log.info "DELETE #{result.status_code.to_s} #{result.status.inspect}"
      result
    end

  end

end
