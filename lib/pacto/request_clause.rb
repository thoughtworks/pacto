module Pacto
  class RequestClause
    attr_reader :host, :method, :schema
    attr_accessor :body

    def initialize(host, definition)
      @host = host
      @definition = definition
      @method = definition['method'].to_s.downcase.to_sym
      @schema = definition['body'] || {}
    end

    def uri
      @uri ||= Pacto::URI.for(host, path, params)
    end

    def body
      JSON::Generator.generate(@definition['body']) if @definition['body']
    end

    def path
      @definition['path']
    end

    def headers
      @definition['headers']
    end

    def params
      @definition['params'] || {}
    end

    def execute
      conn = Faraday.new(:url => uri.to_s) do |faraday|
        faraday.response :logger if Pacto.configuration.logger.level == :debug
        faraday.adapter  Faraday.default_adapter
      end
      conn.send(method) do |req|
        req.headers = headers
      end
    end
  end
end
