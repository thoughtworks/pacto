module Pacto
  module Cops
    class ResponseBodyCop < BodyCop
      def self.section_name
        'response'
      end

      def self.subschema(contract)
        contract.response.schema
      end

      def self.body(request, response)
        response.body
      end
    end
  end
end

Pacto::Cops.register_cop Pacto::Cops::ResponseBodyCop
