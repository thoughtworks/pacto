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

    def validate(response, opt = {})

      unless opt[:body_only]
        if @definition['status'] != response.status
          return ["Invalid status: expected #{@definition['status']} but got #{response.status}"]
        end

        unless @definition['headers'].normalize_keys.subset_of?(response.headers.normalize_keys)
          return ["Invalid headers: expected #{@definition['headers'].inspect} to be a subset of #{response.headers.inspect}"]
        end
      end

      if @definition['body']
        if @definition['body']['type'] && @definition['body']['type'] == 'string'
          validate_as_pure_string response.body
        else
          response.respond_to?(:body) ? validate_as_json(response.body) : validate_as_json(response)
        end
      else
        []
      end
    end

    private

    def validate_as_pure_string response_body
      errors = []
      if @definition['body']['required'] && response_body.nil?
        errors << 'The response does not contain a body'
      end

      pattern = @definition['body']['pattern']
      if pattern && !(response_body =~ Regexp.new(pattern))
        errors << "The response does not match the pattern #{pattern}"
      end

      errors
    end

    def validate_as_json response_body
      JSON::Validator.fully_validate(@definition['body'], response_body)
    end
  end
end
