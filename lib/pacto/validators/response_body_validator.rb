module Pacto
  module Validators
    class ResponseBodyValidator < BodyValidator
      def self.section_name
        'response'
      end

      def self.subschema(contract)
        contract.response.schema
      end
    end
  end
end
