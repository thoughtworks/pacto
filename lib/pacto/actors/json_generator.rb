module Pacto
  module Actors
    class JSONGenerator < Actor
      def build_request(contract, _values = {})
        data = contract.request.to_hash
        data['uri'] = contract.request.uri
        data['body'] = JSON::Generator.generate(data['schema'])
        data['method'] = contract.request.http_method
        Pacto::PactoRequest.new(data)
      end

      def build_response(contract, _values = {})
        data = contract.response.to_hash
        data['body'] = JSON::Generator.generate(data['schema'])
        Pacto::PactoResponse.new(data)
      end
    end
  end
end
