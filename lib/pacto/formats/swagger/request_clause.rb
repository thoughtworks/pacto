# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Swagger
      class RequestClause
        include Pacto::RequestClause

        extend Forwardable
        attr_writer :host
        attr_reader :swagger_api_operation
        def_delegator :swagger_api_operation, :verb, :http_method
        def_delegators :swagger_api_operation, :path

        def initialize(swagger_api_operation, base_data = {})
          @swagger_api_operation = swagger_api_operation
          @host = base_data[:host] || swagger_api_operation.host
          @pattern = Pacto::RequestPattern.for(self)
        end

        def schema
          return nil if body_parameter.nil?
          return nil if body_parameter.schema.nil?
          body_parameter.schema.parse
        end

        def params
          return {} if swagger_api_operation.parameters.nil?

          swagger_api_operation.parameters.select { |p| p.in == 'query' }
        end

        def headers
          return {} if swagger_api_operation.parameters.nil?

          swagger_api_operation.parameters.select { |p| p.in == 'header' }
        end

        def to_hash
          [:http_method, :schema, :path, :headers, :params].each_with_object({}) do | key, hash |
            hash[key.to_s] = send key
          end
        end

        private

        def body_parameter
          return nil if swagger_api_operation.parameters.nil?
          swagger_api_operation.parameters.find { |p| p.in == 'body' }
        end
      end
    end
  end
end
