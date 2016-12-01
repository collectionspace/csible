module Csible

  module HTTP

    def self.convert_params(param_string)
      Hash[CGI.parse(param_string).map {|key,values| [key.to_sym, values[0]||true]}]
    end

    module Helpers

      def check_status!(resource)
        raise "ERROR [#{self.class.to_s.upcase}] #{result.status_code.to_s} #{@result.status.inspect} #{resource}" unless @result.status_code.to_s =~ /^2/
      end

      def print(format = :json)
        if format == :xml
          puts @result.xml.to_xml
        elsif format == :json
          puts JSON.pretty_generate @result.parsed
        else
          ap @result.parsed
        end
      end

    end

    class Request
      include Helpers
      attr_reader :client, :log, :result

      def initialize(client, log = Logger.new(STDOUT))
        @client = client
        @log    = log
        @result = nil
      end

      def do_raw(method, resource, data = {}, headers = {})
        username = client.config.username
        password = client.config.password
        case method
        when :get
          @result = HTTParty.get resource, {
            basic_auth: { username: username, password: password },
            headers: headers,
            query: data,
          }
        when :post
          @result = HTTParty.post resource, {
            basic_auth: { username: username, password: password },
            headers: headers,
            body: data,
          }
        when :put
          @result = HTTParty.put resource, {
            basic_auth: { username: username, password: password },
            headers: headers,
            body: data,
          }
        when :delete
          @result = HTTParty.delete resource, {
            basic_auth: { username: username, password: password },
            headers: headers,
          }
        else
          raise "ERROR invalid or unsupported http method #{method.to_s}"
        end
        @result = CollectionSpace::Response.new result # wrap the response
        log.info "#{method.to_s.upcase} #{@result.status_code.to_s} #{@result.status.inspect} #{resource}"
        @result
      end

    end

    class Get < Request

      # collectionobjects, objectNumber, IN2016.8
      def csid_for(type, attribute, value, fuzzy = false)
        value = value.gsub(/ /, "+")
        expression = fuzzy ? "LIKE '%#{value}%'" : "LIKE '#{value}'"
        search_args = {
          path: type,
          type: "#{type}_common",
          field: attribute,
          expression: expression,
        }
        query   = CollectionSpace::Search.new.from_hash search_args
        @result = client.search(query)
        check_status!(type)
        data    = @result.parsed["abstract_common_list"]
        raise "Search result != 1 for #{type} #{attribute} #{value} #{data}" unless data['totalItems'].to_i == 1
        data['list_item']['csid']
      end

      def execute(type, resource, params = {})
        if type == :path
          @result = client.get resource, { query: params }
        elsif type == :url
          @result = do_raw :get, resource, params
        else
          raise "Unrecognized request type: #{type}"
        end

        check_status!(resource)
        log.info "GET #{result.status_code.to_s} #{result.status.inspect} #{resource}"
        result
      end

      def identifiers_for(path, id)
        identifiers = {}
        @result = client.get path, { query: { kw: id } }
        check_status!(path)
        data    = @result.parsed["abstract_common_list"]
        if data['totalItems'].to_i == 1
          identifiers["csid"] = data['list_item']['csid']
          identifiers["uri"]  = data['list_item']['uri']
        else
          identifiers = nil
        end
        identifiers
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

      def execute(type, resource, payload)
        raise "Payload error" unless payload
        if type == :path
          @result = client.post resource, payload
        elsif type == :url
          @result = do_raw :post, resource, payload
        else
          raise "Unrecognized request type: #{type}"
        end
        check_status!(resource)
        log.info "POST #{result.status_code.to_s} #{result.status.inspect} #{result.headers['Location']}"
        result
      end

    end

    class Put < Request

      def execute(type, resource, payload)
        raise "Payload error" unless payload
        if type == :path
          @result = client.put resource, payload
        elsif type == :url
          @result = do_raw :put, resource, payload
        else
          raise "Unrecognized request type: #{type}"
        end
        check_status!(resource)
        log.info "PUT #{result.status_code.to_s} #{result.status.inspect}"
        result
      end

    end

    class Delete < Request

      def execute(type, resource)
        if type == :path
          @result = client.delete resource
        elsif type == :url
          @result = do_raw :delete, resource
        else
          raise "Unrecognized request type: #{type}"
        end
        check_status!(resource)
        log.info "DELETE #{result.status_code.to_s} #{result.status.inspect} #{resource}"
        result
      end

    end

  end

end
