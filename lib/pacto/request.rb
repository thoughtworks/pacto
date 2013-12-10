module Pacto
  class Request
    attr_reader :host, :method
    attr_accessor :body

    def initialize(host, definition)
      @host = host
      @definition = definition
      @method = definition['method'].to_s.downcase.to_sym
    end

    def uri
      uri = Addressable::URI.parse full_uri
      if uri.scheme.nil?
        uri = Addressable::URI.parse "http://#{full_uri}"
      end
      uri
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
      response = HTTParty.send(method, @host + path, {
        httparty_params_key => normalized_params,
        :headers => headers
      })
      ResponseAdapter.new(response)
    end

    private

    def httparty_params_key
      method == :get ? :query : :body
    end

    def normalized_params
      method == :get ? params : params.to_json
    end
  end
end
