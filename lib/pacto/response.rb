module Pacto
  class Response
    attr_reader :status, :headers, :schema

    def initialize(definition)
      @definition = definition
      @status = @definition['status']
      @headers = @definition['headers']
      @schema = @definition['body']
    end

    def instantiate
      OpenStruct.new(
        'status' => @status,
        'headers' => @headers,
        'body' => JSON::Generator.generate(@schema)
      )
    end

    # FIXME: validate is a huge method =(. Needs refactoring
    # rubocop:disable MethodLength
    def validate(response, opt = {})

      unless opt[:body_only]
        status, description = response.status
        if @definition['status'] != status
          return ["Invalid status: expected #{@definition['status']} but got #{status}"]
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
    # rubocop:enable MethodLength

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
      JSON::Validator.fully_validate(@definition['body'], response_body, :version => :draft3)
    end
  end
end
