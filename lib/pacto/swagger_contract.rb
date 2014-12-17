# -*- encoding : utf-8 -*-

require 'pacto/swagger/request_clause'
require 'pacto/swagger/response_clause'

module Pacto
  class SwaggerContract < Pacto::Contract
    attr_reader :swagger_api_operation

    def initialize(swagger_api_operation, base_data = {})
      @swagger_api_operation = swagger_api_operation
      host = base_data.delete(:host) || swagger_api_operation.host
      default_response = swagger_api_operation.default_response
      request_clause = Pacto::Swagger::RequestClause.new(swagger_api_operation, host: host)

      if default_response.nil?
        logger.warn("No response defined for #{swagger_api_operation.full_name}")
        response_clause = Pacto::ResponseClause.new(status: 200)
      else
        response_clause = Pacto::Swagger::ResponseClause.new(default_response)
      end

      examples = build_examples(default_response)
      super base_data.merge(
              id: swagger_api_operation.operationId,
              name: swagger_api_operation.full_name,
              request: request_clause, response: response_clause,
              examples: examples
            )
    end

    private

    def build_examples(response)
      return nil if response.nil? || response.examples.nil? || response.examples.empty?

      {
        default: {
          request: {}, # Swagger doesn't have a clear way to capture request examples
          response: {
            body: response.examples.values.first.parse
          }
        }
      }
    rescue => e # FIXME: Only parsing errors?
      logger.warn("Error while trying to parse response example for #{op.full_name}")
      logger.debug("  Error details: #{e.inspect}")
      nil
    end
  end
end
