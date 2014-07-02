
module Pacto
  module Cops
    class BodyCop
      def self.section_name
        fail 'section name should be provided by subclass'
      end

      def self.subschema(_contract)
        fail 'override to return the proper subschema the contract'
      end

      def self.investigate(_request, response, contract)
        schema = subschema(contract)
        if schema && !schema.empty?
          schema['id'] = contract.file unless schema.key? 'id'
          validate_as_json(schema, response.body)
        end || []
      end

      def self.validate_as_json(schema, body)
        body = body.body if body.respond_to? :body
        JSON::Validator.fully_validate(schema, body, version: :draft3)
      end
    end
  end
end
