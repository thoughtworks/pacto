module Pacto
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

    def validate(response)
      if @definition['status'] != response.status
        return [ "Invalid status: expected #{@definition['status']} but got #{response.status}" ]
      end
      
      unless @definition['headers'].normalize_keys.subset_of?(response.headers.normalize_keys)
        return [ "Invalid headers: expected #{@definition['headers'].inspect} to be a subset of #{response.headers.inspect}" ]
      end
      
      if @definition['body']
        JSON::Validator.fully_validate(@definition['body'], response.body)
      else
        []
      end
    end
  end
end
