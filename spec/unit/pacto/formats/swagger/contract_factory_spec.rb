# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Swagger
      describe ContractFactory do
        let(:swagger_file) { 'spec/fixtures/swagger/petstore.yaml' }
        let(:expected_schema) do
          {
            'type' => 'array',
            'items' => {
              'required' => %w(id name),
              'properties' => {
                'id' => { 'type' => 'integer', 'format' => 'int64' },
                'name' => { 'type' => 'string' },
                'tag' => { 'type' => 'string' }
              }
            }
          }
        end
        describe '#load_hints' do
          pending 'loads hints from Swagger' do
            hints = subject.load_hints(swagger_file)
            expect(hints.size).to eq(3) # number of API operations
            hints.each do | hint |
              expect(hint).to be_a_kind_of(Pacto::Generator::Hint)
              expect(hint.host).to eq('petstore.swagger.wordnik.com')
              expect([:get, :post]).to include(hint.http_method)
              expect(hint.path).to match(/\/pets/)
            end
          end
        end

        describe '#build_from_file' do
          it 'loads Contracts from Swagger' do
            contracts = subject.build_from_file(swagger_file)
            expect(contracts.size).to eq(3) # number of API operations
            contracts.each do | contract |
              expect(contract).to be_a(Pacto::Formats::Swagger::Contract)

              request_clause = contract.request
              expect(request_clause.host).to eq('petstore.swagger.wordnik.com')
              expect([:get, :post]).to include(request_clause.http_method)
              expect(request_clause.path).to match(/\/pets/)

              response_clause = contract.response
              if request_clause.http_method == :get
                expect(response_clause.status).to eq(200)
              else
                expect(response_clause.status).to eq(201)
              end
              expect(response_clause.schema).to eq(expected_schema) if response_clause.status == 200
            end
          end
        end
      end
    end
  end
end
