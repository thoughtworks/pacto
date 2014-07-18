module Pacto
  module Cops
    class RequestBodyCop < BodyCop
      def self.section_name
        'request'
      end

      def self.subschema(contract)
        contract.request.schema
      end

      def self.body(request, _response)
        request.body
      end
    end
  end
end

Pacto::Cops.register_cop Pacto::Cops::RequestBodyCop
