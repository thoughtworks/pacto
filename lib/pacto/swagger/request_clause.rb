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

      def headers
        h = {}
        swagger_api_operation.parameters.each do |parameter|
          # Note: Can't use parameter.default because it conflicts w/ Hash#default method!
          h[parameter.name] = parameter['default'] if parameter.in == 'header'
        end if swagger_api_operation.parameters
        h
      end

      def schema
        schema = {}
        if swagger_api_operation.parameters
          body_param = swagger_api_operation.parameters.find { |p| p.in == 'body' }
          schema = body_param.schema if body_param
        end
        schema
      end
    end
  end
end
