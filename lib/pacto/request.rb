module Pacto
  class Request
    attr_reader :host

    def initialize(host, definition)
      @host = host
      @definition = definition
    end

    def method
      @definition['method'].to_s.downcase.to_sym
    end

    def path
      @definition['path']
    end

    def headers
      @definition['headers']
    end

    def params
      @definition['params']
    end

    def absolute_uri
      @host + path
    end

    def full_uri
      return absolute_uri if params.empty?

      uri = Addressable::URI.new
      uri.query_values = params

      absolute_uri + '?' + uri.query
    end

    def execute
      conn = Faraday.new(:url => @host + path) do |faraday|
        faraday.response :logger if Pacto.configuration.logger.level == :debug
        faraday.adapter  Faraday.default_adapter
      end
      conn.send(method) do |req|
        req.headers = headers
      end
    end
  end
end
