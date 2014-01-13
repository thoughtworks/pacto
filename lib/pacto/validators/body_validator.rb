module Pacto
  module Validators
    class BodyValidator
      def self.section_name
        fail 'section name should be provided by subclass'
      end

      def self.validate(schema, body)
        if schema
          if schema['type'] && schema['type'] == 'string'
            validate_as_pure_string schema, body.body
          else
            body.respond_to?(:body) ? validate_as_json(schema, body.body) : validate_as_json(schema, body)
          end
        else
          []
        end
      end

      private

      def self.validate_as_pure_string(schema, body)
        errors = []
        if schema['required'] && body.nil?
          errors << "The #{section_name} does not contain a body"
        end

        pattern = schema['pattern']
        if pattern && !(body =~ Regexp.new(pattern))
          errors << "The #{section_name} does not match the pattern #{pattern}"
        end

        errors
      end

      def self.validate_as_json(schema, body)
        JSON::Validator.fully_validate(schema, body, :version => :draft3)
      end
    end
  end
end
