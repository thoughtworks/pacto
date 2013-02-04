module Contracts
  class Response
    def initialize(definition)
      @definition = definition
    end

    def instantiate(attributes)
      {
        'status' => @definition['status'],
        'headers' => @definition['headers'],
        'body' => JSON::Generator.generate(@definition['body'], attributes)
      }
    end
  end
end
