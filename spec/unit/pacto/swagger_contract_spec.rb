# -*- encoding : utf-8 -*-
require 'unit/pacto/contract_spec'

module Pacto
  describe SwaggerContract do
    let(:swagger_yaml) do
      ''"
      swagger: '2.0'
      info:
        title: Sample API
        version: N/A
      consumes:
      - application/json
      produces:
      - application/json
      paths:
        /:
          get:
            operationId: sample
            responses:
              200:
                description: |-
                  Success.
      "''
    end
    let(:swagger_definition) do
      ::Swagger.build_api(swagger_yaml, format: :yaml)
    end
    let(:api_operation) do
      swagger_definition.operations.first
    end
    let(:adapter) { double 'provider' }
    let(:file) { 'contract.json' }
    let(:consumer_driver) { double }
    let(:provider_actor) { double }

    subject(:contract) do
      described_class.new(api_operation, file: file)
    end

    it_behaves_like 'a contract'
  end
end
