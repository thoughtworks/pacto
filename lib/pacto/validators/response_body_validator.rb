module Pacto
  module Validators
    class ResponseBodyValidator
      def initialize(app)
        @app = app
      end

      def call env
        if env[:validation_results].empty? # skip body validation if we already have other errors
          expected_body = env[:contract].response.schema
          actual_body = env[:actual_response]
          errors = self.class.validate(expected_body, actual_body)
          env[:validation_results].concat errors.compact
        end
        @app.call env
      end

      def self.validate expected_response, actual_response
        if expected_response
          if expected_response['type'] && expected_response['type'] == 'string'
            validate_as_pure_string expected_response, actual_response.body
          else
            actual_response.respond_to?(:body) ? validate_as_json(expected_response, actual_response.body) : validate_as_json(expected_response, actual_response)
          end
        else
          []
        end
      end

      private

      def self.validate_as_pure_string expected_response, response_body
        errors = []
        if expected_response['required'] && response_body.nil?
          errors << 'The response does not contain a body'
        end

        pattern = expected_response['pattern']
        if pattern && !(response_body =~ Regexp.new(pattern))
          errors << "The response does not match the pattern #{pattern}"
        end

        errors
      end

      def self.validate_as_json expected_response, response_body
        JSON::Validator.fully_validate(expected_response, response_body, :version => :draft3)
      end
    end
  end
end
