module Pacto
  module Cops
    class RequestBodyCop < BodyCop
      def self.section_name
        'request'
      end

      def self.subschema(contract)
        contract.request.schema
      end
    end
  end
end
