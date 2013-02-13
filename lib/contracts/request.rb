module Contracts
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

    def execute
      response = HTTParty.send(method, @host + path, {
        httparty_params_key => params,
        :headers => headers
      })
      ResponseAdapter.new(response)
    end

    private
    def httparty_params_key
      method == :get ? :query : :body
    end
  end
end
