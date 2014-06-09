module Pacto
  module Actors
    class JSONGenerator
      def self.build_request(contract, values = {})
        data = contract.request.to_hash
        data['uri'] = contract.request.uri
        data['body'] = JSON::Generator.generate(data['schema'])
        Pacto::PactoRequest.new(data)
      end

      def self.build_response(contract, values = {})
        data = contract.response.to_hash
        data['body'] = JSON::Generator.generate(data['schema'])
        Pacto::PactoResponse.new(data)
      end
    end
  end
end
