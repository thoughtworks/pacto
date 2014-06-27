module Pacto
  module Validators
    class BodyValidator
      def self.section_name
        fail 'section name should be provided by subclass'
      end

      def self.subschema(_contract)
        fail 'override to return the proper subschema the contract'
      end

      def self.validate(contract, body)
        schema = subschema(contract)
        if schema
          schema['id'] = contract.file unless schema.key? 'id'
          validate_as_json(schema, body)
        end || []
      end

      def self.validate_as_json(schema, body)
        body = body.body if body.respond_to? :body
        JSON::Validator.fully_validate(schema, body, schema: :draft3)
      end
    end
  end
end
