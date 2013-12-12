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
      if @schema && !@schema.empty?
        OpenStruct.new(
          'status' => @definition['status'],
          'headers' => @definition['headers'],
          'body' => JSON::Generator.generate(@schema)
        )
      else
        OpenStruct.new(
          'status' => @definition['status'],
          'headers' => @definition['headers']
        )
      end
    end

    # FIXME: validate is a huge method =(. Needs refactoring
    # rubocop:disable MethodLength
    def validate(response, opt = {})

      unless opt[:body_only]
        status, _description = response.status
        if @definition['status'] != status
          return ["Invalid status: expected #{@definition['status']} but got #{status}"]
        end

        headers_to_validate = @definition['headers'].dup
        expected_location = headers_to_validate.delete 'Location'
        unless headers_to_validate.normalize_keys.subset_of?(response.headers.normalize_keys)
          return ["Invalid headers: expected #{@definition['headers'].inspect} to be a subset of #{response.headers.inspect}"]
        end

        if expected_location
          location_template = Addressable::Template.new(expected_location)
          location = response.headers['Location']
          if location.nil?
            return ['Expected a Location Header in the response']
          elsif !location_template.match(Addressable::URI.parse(location))
            return ["Location mismatch: expected URI #{location} to match URI Template #{location_template.pattern}"]
          end
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
