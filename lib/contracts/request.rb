module Contracts
  class Request
    def initialize(definition)
      @definition = definition
    end

    def method
      @definition['method']
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
