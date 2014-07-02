module Pacto
  module Validators
    class RequestBodyValidator < BodyValidator
      def self.section_name
        'request'
      end

      def self.subschema(contract)
        contract.request.schema
      end
    end
  end
end
