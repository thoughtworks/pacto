module Pacto
  module Actors
    class JSONGenerator
      def self.build_request(request_clause)
        data = request_clause.to_hash
        data['uri'] = request_clause.uri
        data['body'] = JSON::Generator.generate(data['schema'])
        Pacto::PactoRequest.new(data)
      end

      def self.build_response(response_clause)
        data = response_clause.to_hash
        data['body'] = JSON::Generator.generate(data['schema'])
        Pacto::PactoResponse.new(data)
      end
    end
  end
end
