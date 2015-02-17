# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Swagger
      class ResponseClause < Pacto::ResponseClause
        attr_reader :swagger_response

        def initialize(swagger_response, base_data = {})
          @swagger_response = swagger_response
          data = {}.tap do | response_clause |
            response_clause[:status] = swagger_response.status_code || 200
            response_clause[:schema] = swagger_response.schema.parse unless swagger_response.schema.nil?
          end

          super base_data.merge(data)
        end
      end
    end
  end
end
