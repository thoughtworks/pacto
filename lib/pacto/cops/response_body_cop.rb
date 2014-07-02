module Pacto
  module Cops
    class ResponseBodyCop < BodyCop
      def self.section_name
        'response'
      end

      def self.subschema(contract)
        contract.response.schema
      end
    end
  end
end
