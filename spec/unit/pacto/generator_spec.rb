module Pacto
  describe Generator do
    let(:record_host) do
      'http://example.com'
    end
    let(:request_clause) { Fabricate(:request_clause, :params => {'api_key' => "<%= ENV['MY_API_KEY'] %>"}) }
    let(:request) do
      request_clause.to_pacto_request
    end
    let(:response_adapter) do
      Faraday::Response.new(
        :status => 200,
        :response_headers => {
          'Date' => [Time.now],
          'Server' => ['Fake Server'],
          'Content-Type' => ['application/json'],
          'Vary' => ['User-Agent']
        },
        :body => 'dummy body' # body is just a string
      )
    end
    let(:filtered_request_headers) { double('filtered_response_headers') }
    let(:filtered_response_headers) { double('filtered_response_headers') }
    let(:response_body_schema) { '{"message": "dummy generated schema"}' }
    let(:version) { 'draft3' }
    let(:schema_generator) { double('schema_generator') }
    let(:validator) { double('validator') }
    let(:filters) { double :filters }
    let(:request_file) { 'request.json' }
    let(:generator) { described_class.new version, schema_generator, validator, filters }

    def pretty(obj)
      MultiJson.encode(obj, :pretty => true).gsub(/^$\n/, '')
    end

    describe '#generate_from_partial_contract' do
      # TODO: Deprecate partial contracts?
      let(:request_contract) do
        double(
          :request => request
        )
      end
      let(:generated_contract) { Fabricate(:contract) }
      before do
        Pacto.should_receive(:load_contract).with(request_file, record_host).and_return request_contract
        request_contract.should_receive(:execute).and_return([request, response_adapter])
      end

      it 'parses the request' do
        generator.should_receive(:save).with(request_file, request, anything)
        generator.generate_from_partial_contract request_file, record_host
      end

      it 'fetches a response' do
        generator.should_receive(:save).with(request_file, anything, response_adapter)
        generator.generate_from_partial_contract request_file, record_host
      end

      it 'saves the result' do
        generator.should_receive(:save).with(request_file, request, response_adapter).and_return generated_contract
        expect(generator.generate_from_partial_contract request_file, record_host).to eq(generated_contract)
      end
    end

    describe '#save' do
      before do
        filters.should_receive(:filter_request_headers).with(request, response_adapter).and_return filtered_request_headers
        filters.should_receive(:filter_response_headers).with(request, response_adapter).and_return filtered_response_headers
      end
      context 'invalid schema' do
        it 'raises an error if schema generation fails' do
          JSON::SchemaGenerator.should_receive(:generate).and_raise ArgumentError.new('Could not generate schema')
          expect { generator.save request_file, request, response_adapter }.to raise_error
        end

        it 'raises an error if the generated contract is invalid' do
          JSON::SchemaGenerator.should_receive(:generate).and_return response_body_schema
          validator.should_receive(:validate).and_raise InvalidContract.new('dummy error')
          expect { generator.save request_file, request, response_adapter }.to raise_error
        end
      end

      context 'valid schema' do
        let(:raw_contract) do
          JSON::SchemaGenerator.should_receive(:generate).with(request_file, response_adapter.body, Pacto.configuration.generator_options).and_return response_body_schema
          validator.should_receive(:validate).and_return true
          generator.save request_file, request, response_adapter
        end
        subject(:generated_contract) { JSON.parse raw_contract }

        it 'sets the schema to the generated json-schema' do
          expect(subject['response']['schema']).to eq(JSON.parse response_body_schema)
        end

        it 'sets the request attributes' do
          generated_request = subject['request']
          expect(generated_request['params']).to eq(request.uri.query_values)
          expect(generated_request['path']).to eq(request.uri.path)
        end

        it 'preserves ERB in the request params' do
          generated_request = subject['request']
          expect(generated_request['params']).to eq('api_key' => "<%= ENV['MY_API_KEY'] %>")
        end

        it 'normalizes the request method' do
          generated_request = subject['request']
          expect(generated_request['method']).to eq(request.method.downcase.to_s)
        end

        it 'sets the response attributes' do
          generated_response = subject['response']
          expect(generated_response['status']).to eq(response_adapter.status)
        end

        it 'generates pretty JSON' do
          expect(raw_contract).to eq(pretty(subject))
        end
      end
    end
  end
end
