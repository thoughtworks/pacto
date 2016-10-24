# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Swagger
      class ResponseClause
        extend Forwardable
        include Pacto::ResponseClause
        attr_reader :swagger_response

        def_delegators :swagger_response, :schema

        def initialize(swagger_response, _base_data = {})
          @swagger_response = swagger_response
        end

        def status
          swagger_response.status_code || 200
        end

        def headers
          swagger_response.headers || {}
        end

        def schema
          return nil unless swagger_response.schema
          swagger_response.schema.parse
        end

        def to_hash
          [:status, :headers, :schema].each_with_object({}) do | key, hash |
            hash[key.to_s] = send key
          end
        end
      end
    end
  end
end
