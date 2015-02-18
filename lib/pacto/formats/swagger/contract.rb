# -*- encoding : utf-8 -*-

require 'pacto/formats/swagger/request_clause'
require 'pacto/formats/swagger/response_clause'

module Pacto
  module Formats
    module Swagger
      class Contract < Pacto::Dash
        include Pacto::Contract

        attr_reader :swagger_api_operation

        property :id
        property :file
        property :request,  required: true
        # Although I'd like response to be required, it complicates
        # the partial contracts used the rake generation task...
        # yet another reason I'd like to deprecate that feature
        property :response # , required: true
        property :values, default: {}
        # Gotta figure out how to use test doubles w/ coercion
        coerce_key :request,  RequestClause
        coerce_key :response, ResponseClause
        property :examples
        property :name, required: true
        property :adapter, default: proc { Pacto.configuration.adapter }
        property :consumer, default: proc { Pacto.configuration.default_consumer }
        property :provider, default: proc { Pacto.configuration.default_provider }

        def initialize(swagger_api_operation, base_data = {}) # rubocop:disable Metrics/MethodLength
          if base_data[:file]
            base_data[:file] = Addressable::URI.convert_path(File.expand_path(base_data[:file])).to_s
            base_data[:name] ||= base_data[:file]
          end
          base_data[:id] ||= (base_data[:summary] || base_data[:file])

          @swagger_api_operation = swagger_api_operation
          host = base_data.delete(:host) || swagger_api_operation.host
          default_response = swagger_api_operation.default_response
          request_clause = Pacto::Formats::Swagger::RequestClause.new(swagger_api_operation, host: host)

          if default_response.nil?
            logger.warn("No response defined for #{swagger_api_operation.full_name}")
            response_clause = ResponseClause.new(status: 200)
          else
            response_clause = ResponseClause.new(default_response)
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

          if response.examples.empty?
            response_body = nil
          else
            response_body = response.examples.values.first
          end

          {
            default: {
              request: {}, # Swagger doesn't have a clear way to capture request examples
              response: {
                body: response_body
              }
            }
          }
        rescue => e # FIXME: Only parsing errors?
          logger.warn("Error while trying to parse response example for #{swagger_api_operation.full_name}")
          logger.debug("  Error details: #{e.inspect}")
          nil
        end
      end
    end
  end
end
