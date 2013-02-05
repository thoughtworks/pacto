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
  end
end
