module Pacto
  module Cops
    class BodyCop
      def self.section_name
        fail 'section name should be provided by subclass'
      end

      def self.subschema(_contract)
        fail 'override to return the proper subschema of the contract'
      end

      def self.body(request, response)
        fail 'override to return the proper body from the request or response'
      end

      def self.investigate(_request, response, contract)
        schema = subschema(contract)
        if schema && !schema.empty?
          schema['id'] = contract.file unless schema.key? 'id'
          validate_as_json(schema, body(_request, response))
        end || []
      end

      def self.validate_as_json(schema, body)
        if schema['type'] == 'string'
          # Is it better to check body is not nil, or body is a string?
          body = body.inspect unless body.nil?
        end
        JSON::Validator.fully_validate(schema, body, version: :draft3)
      end
    end
  end
end
