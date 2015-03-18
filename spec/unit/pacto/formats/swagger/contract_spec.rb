# -*- encoding : utf-8 -*-
require 'unit/pacto/contract_spec'

module Pacto
  module Formats
    module Swagger
      describe Contract do
        let(:swagger_yaml) do
          %(
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
                    examples:
                      application/json: |-
                        {
                          "item": {
                            "id": 45,
                            "name": "basketball"
                          }
                        }
          )
        end
        let(:swagger_definition) do
          ::Swagger.build(swagger_yaml, format: :yaml)
        end
        let(:api_operation) do
          swagger_definition.operations.first
        end
        let(:adapter) { double 'provider' }
        let(:file) { Tempfile.new(['swagger', '.yaml']).path }
        let(:consumer_driver) { double }
        let(:provider_actor) { double }

        subject(:contract) do
          described_class.new(api_operation, file: file)
        end

        describe 'contract examples' do
          let(:example) { contract.examples }
          it { expect(example).to be_truthy }
          it { expect(example[:default][:response][:body]).to be_a(Hash) }
        end

        it_behaves_like 'a contract'
      end
    end
  end
end
