module Contracts
  class Response
    def initialize(definition)
      @definition = definition
    end

    def instantiate
      OpenStruct.new({
        'status' => @definition['status'],
        'headers' => @definition['headers'],
        'body' => JSON::Generator.generate(@definition['body'])
      })
    end
  end
end
