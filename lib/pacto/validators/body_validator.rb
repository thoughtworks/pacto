module Pacto
  module Validators
    class BodyValidator
      def self.section_name
        fail 'section name should be provided by subclass'
      end

      def self.subschema(contract)
        fail 'override to return the proper subschema the contract'
      end

      # FIXME: https://github.com/thoughtworks/pacto/issues/10#issuecomment-31281238
      # rubocop:disable MethodLenth
      def self.validate(contract, body)
        schema = subschema(contract)
        if schema
          schema['id'] = contract.file unless schema.key? 'id'
          if schema['type'] && schema['type'] == 'string'
            validate_as_pure_string schema, body.body
          else
            validate_as_json(schema, body)
          end
        end || []
      end
      # rubocop:enable MethodLenth

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
        body = body.body if body.respond_to? :body
        JSON::Validator.fully_validate(schema, body, :version => :draft3)
      end
    end
  end
end
