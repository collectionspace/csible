module Csible
  module HTTP
    def self.convert_params(param_string)
      Hash[CGI.parse(param_string).map { |key, values| [key.to_sym, values[0] || true] }]
    end

    module Helpers
      def check_status!(resource)
        raise "ERROR [#{self.class.to_s.upcase}] #{result.status_code} #{@result.status.inspect} #{resource}" unless @result.status_code.to_s =~ /^2/
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
    end

    class Get < Request
      # collectionobjects, objectNumber, IN2016.8
      def csid_for(type, attribute, value, fuzzy = false)
        value = value.tr(' ', '%').tr('*', '%')
        expression = fuzzy ? "LIKE '%#{value}%'" : "LIKE '#{value}'"
        search_args = {
          path: type,
          type: "#{type}_common",
          field: attribute,
          expression: expression
        }
        query   = CollectionSpace::Search.new.from_hash search_args
        @result = client.search(query)
        check_status!(type)
        data = @result.parsed['abstract_common_list']
        raise "Search result != 1 for #{type} #{attribute} #{value} #{data}" unless data['totalItems'].to_i == 1

        data['list_item']['csid']
      end

      def execute(resource, params = {})
        @result = client.get resource, query: params
        check_status!(resource)
        log.info "GET #{result.status_code} #{result.status.inspect} #{resource}"
        result
      end

      def identifiers_for(path, id)
        identifiers = {}
        @result = client.get path, query: { kw: id }
        check_status!(path)
        data = @result.parsed['abstract_common_list']
        if data['totalItems'].to_i == 1
          identifiers['csid'] = data['list_item']['csid']
          identifiers['uri']  = data['list_item']['uri']
        else
          identifiers = nil
        end
        identifiers
      end

      def list(path, file, params = {})
        add_headers = true
        client.all(path, params).each do |record|
          Csible.append_csv(file, record.keys) if add_headers
          Csible.append_csv(file, record.values)
          log.info "LIST [#{record['uri']}]"
          add_headers = false
        end
      end
    end

    class Post < Request
      def execute(resource, payload, params = {})
        raise 'Payload error' unless payload

        @result = client.post resource, payload, query: params
        check_status!(resource)
        log.info "POST #{result.status_code} #{result.status.inspect} #{result.headers['Location']}"
        result
      end
    end

    class Put < Request
      def execute(resource, payload)
        raise 'Payload error' unless payload

        @result = client.put resource, payload
        check_status!(resource)
        log.info "PUT #{result.status_code} #{result.status.inspect}"
        result
      end
    end

    class Delete < Request
      def execute(resource)
        @result = client.delete resource
        check_status!(resource)
        log.info "DELETE #{result.status_code} #{result.status.inspect} #{resource}"
        result
      end
    end
  end
end
