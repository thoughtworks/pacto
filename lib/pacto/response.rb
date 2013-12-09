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
        'status' => @definition['status'],
        'headers' => @definition['headers'],
        'body' => JSON::Generator.generate(@definition['body'])
      )
    end

    # FIXME: validate is a huge method =(. Needs refactoring
    # rubocop:disable MethodLength
    def validate(response, opt = {})
      unless opt[:body_only]
        status, _description = response.status
        error = Pacto::Validators::ResponseStatusValidator.validate @definition['status'], status
        return error unless error.nil?

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

      Pacto::Validators::ResponseBodyValidator.validate @definition['body'], response
    end
    # rubocop:enable MethodLength
  end
end
