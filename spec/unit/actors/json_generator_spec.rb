# -*- encoding : utf-8 -*-
RSpec.shared_examples 'uses defaults' do
  it 'uses the default values for the request' do
    expect(request.body['foo']).to eq 'custom default value'
  end

  it 'uses the default values for the response' do
    response = generator.build_response contract # , request
    expect(response.body['foo']).to eq 'custom default value'
  end
end

RSpec.shared_examples 'uses dumb values' do
  it 'uses dumb values (request)' do
    expect(request.body['foo']).to eq 'bar'
  end

  it 'uses dumb values (response)' do
    response = generator.build_response contract # , request
    expect(response.body['foo']).to eq 'bar'
  end
end

module Pacto
  module Actors
    describe JSONGenerator do
      subject(:generator) { described_class.new }
      let(:request_clause) { Fabricate(:request_clause, schema: schema) }
      let(:response_clause) { Fabricate(:response_clause, schema: schema) }
      let(:contract) { Fabricate(:contract, request: request_clause, response: response_clause) }
      let(:request) { generator.build_request contract }

      context 'using default values from schema' do
        context 'draft3' do
          let(:schema) do
            {
              '$schema'  => 'http://json-schema.org/draft-03/schema#',
              'type'     => 'object',
              'required' => true,
              'properties' => {
                'foo' => {
                  'type'     => 'string',
                  'required' => true,
                  'default'  => 'custom default value'
                }
              }
            }
          end
          include_examples 'uses defaults'
        end
        context 'draft4' do
          let(:schema) do
            {
              '$schema'  => 'http://json-schema.org/draft-04/schema#',
              'type'     => 'object',
              'required' => ['foo'],
              'properties' => {
                'foo' => {
                  'type'     => 'string',
                  'default'  => 'custom default value'
                }
              }
            }
          end
          skip 'draft4 is not supported by JSONGenerator'
          # include_examples 'uses defaults'
        end
      end
      context 'using dumb values (no defaults)' do
        context 'draft3' do
          let(:schema) do
            {
              '$schema'  => 'http://json-schema.org/draft-03/schema#',
              'type'     => 'object',
              'required' => true,
              'properties' => {
                'foo' => {
                  'type'     => 'string',
                  'required' => true
                }
              }
            }
          end
          include_examples 'uses dumb values'
        end
        context 'draft4' do
          let(:schema) do
            {
              '$schema'  => 'http://json-schema.org/draft-04/schema#',
              'type'     => 'object',
              'required' => ['foo'],
              'properties' => {
                'foo' => {
                  'type'     => 'string'
                }
              }
            }
          end
          skip 'draft4 is not supported by JSONGenerator'
          # include_examples 'uses dumb values'
        end
      end
    end
  end
end
