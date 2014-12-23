# -*- encoding : utf-8 -*-
module Pacto
  module Actors
    class JSONGenerator < Actor
      def build_request(contract, values = {})
        rc = contract.request
        data = {}
        data['method'] = rc.http_method
        data['uri'] = rc.uri(values)
        data['headers'] = rc.headers
        data['body'] = JSON::Generator.generate(rc.schema)
        Pacto::PactoRequest.new(data)
      end

      def build_response(contract, _values = {})
        rc = contract.response
        data = {
          status: rc.status,
          headers: rc.headers,
          body: JSON::Generator.generate(rc.schema)
        }
        Pacto::PactoResponse.new(data)
      end
    end
  end
end
