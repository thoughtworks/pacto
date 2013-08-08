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
      @errors = []
      if @definition['status'] != response.status
        @errors << "Invalid status: expected #{@definition['status']} but got #{response.status}"
      end
      unless @definition['headers'].normalize_keys.subset_of?(response.headers.normalize_keys)
        @errors << "Invalid headers: expected #{@definition['headers'].inspect} to be a subset of #{response.headers.inspect}"
      end
      @errors << JSON::Validator.fully_validate(@definition['body'], response.body)
      @errors.flatten
    end
  end
end
