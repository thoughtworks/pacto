module Pacto
  class Request
    def initialize(host, definition)
      @host = host
      @definition = definition
    end

    def host
      @host
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
