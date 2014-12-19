# -*- encoding : utf-8 -*-
module Pacto
  module Swagger
    class RequestClause < Pacto::RequestClause
      attr_reader :swagger_api_operation

      def initialize(swagger_api_operation, base_data = {})
        @swagger_api_operation = swagger_api_operation
        host = base_data[:host] || swagger_api_operation.host
        super base_data.merge(host: host,
                              http_method: swagger_api_operation.verb,
                              path: swagger_api_operation.path)
      end

      def http_method
        swagger_api_operation.verb.downcase.to_sym
      end
    end
  end
end
