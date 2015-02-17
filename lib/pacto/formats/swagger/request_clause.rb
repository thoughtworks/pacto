# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Swagger
      class RequestClause < Pacto::RequestClause
        def initialize(swagger_api_operation, base_data = {})
          host = base_data[:host] || swagger_api_operation.host
          super base_data.merge(host: host,
                                http_method: swagger_api_operation.verb,
                                path: swagger_api_operation.path)
        end
      end
    end
  end
end
