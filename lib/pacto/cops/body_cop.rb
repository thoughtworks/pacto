# -*- encoding : utf-8 -*-
module Pacto
  module Cops
    class BodyCop
      KNOWN_CLAUSES = [:request, :response]

      def self.validates(clause)
        fail ArgumentError, "Unknown clause: #{clause}" unless KNOWN_CLAUSES.include? clause
        @clause = clause
      end

      def self.investigate(request, response, contract)
        # eval "is a security risk" and local_variable_get is ruby 2.1+ only, so...
        body = { request: request, response: response }[@clause].body
        schema = contract.send(@clause).schema
        if schema && !schema.empty?
          schema['id'] = contract.file unless schema.key? 'id'
          JSON::Validator.fully_validate(schema, body, version: :draft3)
        end || []
      end
    end
  end
end
