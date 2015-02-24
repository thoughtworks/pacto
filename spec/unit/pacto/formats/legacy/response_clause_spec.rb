# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Legacy
      describe ResponseClause do
        let(:body_definition) do
          Fabricate(:schema)
        end

        let(:definition) do
          {
            'status' => 200,
            'headers' => {
              'Content-Type' => 'application/json'
            },
            'schema' => body_definition
          }
        end

        subject(:response) { described_class.new(definition) }

        it 'has a status' do
          expect(response.status).to eq(200)
        end

        it 'has a headers hash' do
          expect(response.headers).to eq(
            'Content-Type' => 'application/json'
          )
        end

        it 'has a schema' do
          expect(response.schema).to eq(body_definition)
        end

        it 'has a default value for the schema' do
          definition.delete 'schema'
          response = described_class.new(definition)
          expect(response.schema).to eq(Hash.new)
        end

      end
    end
  end
end
