module Pacto
  describe Generator do
    let(:record_host) do
      'http://example.com'
    end
    let(:request_clause) { Fabricate(:request_clause, params: { 'api_key' => "<%= ENV['MY_API_KEY'] %>" }) }
    let(:response_adapter) do
      Faraday::Response.new(
        status: 200,
        response_headers: {
          'Date' => [Time.now],
          'Server' => ['Fake Server'],
          'Content-Type' => ['application/json'],
          'Vary' => ['User-Agent']
        },
        body: 'dummy body' # body is just a string
      )
    end
    let(:filtered_request_headers) { double('filtered_response_headers') }
    let(:filtered_response_headers) { double('filtered_response_headers') }
    let(:response_body_schema) { '{"message": "dummy generated schema"}' }
    let(:version) { 'draft3' }
    let(:schema_generator) { double('schema_generator') }
    let(:validator) { double('validator') }
    let(:filters) { double :filters }
    let(:consumer) { double 'consumer' }
    let(:request_file) { 'request.json' }
    let(:generator) { described_class.new version, schema_generator, validator, filters, consumer }
    let(:request_contract) do
      Fabricate(:partial_contract, request: request_clause, file: request_file)
    end
    let(:request) do
      Pacto.configuration.default_consumer.build_request request_contract
    end

    def pretty(obj)
      MultiJson.encode(obj, pretty: true).gsub(/^$\n/, '')
    end

    describe '#generate_from_partial_contract' do
      # TODO: Deprecate partial contracts?
      let(:generated_contract) { Fabricate(:contract) }
      before do
        expect(Pacto).to receive(:load_contract).with(request_file, record_host).and_return request_contract
        expect(consumer).to receive(:request).with(request_contract).and_return([request, response_adapter])
      end

      it 'parses the request' do
        expect(generator).to receive(:save).with(request_file, request, anything)
        generator.generate_from_partial_contract request_file, record_host
      end

      it 'fetches a response' do
        expect(generator).to receive(:save).with(request_file, anything, response_adapter)
        generator.generate_from_partial_contract request_file, record_host
      end

      it 'saves the result' do
        expect(generator).to receive(:save).with(request_file, request, response_adapter).and_return generated_contract
        expect(generator.generate_from_partial_contract request_file, record_host).to eq(generated_contract)
      end
    end

    describe '#save' do
      before do
        expect(filters).to receive(:filter_request_headers).with(request, response_adapter).and_return filtered_request_headers
        expect(filters).to receive(:filter_response_headers).with(request, response_adapter).and_return filtered_response_headers
      end
      context 'invalid schema' do
        it 'raises an error if schema generation fails' do
          expect(schema_generator).to receive(:generate).and_raise ArgumentError.new('Could not generate schema')
          expect { generator.save request_file, request, response_adapter }.to raise_error
        end

        it 'raises an error if the generated contract is invalid' do
          expect(schema_generator).to receive(:generate).and_return response_body_schema
          expect(validator).to receive(:validate).and_raise InvalidContract.new('dummy error')
          expect { generator.save request_file, request, response_adapter }.to raise_error
        end
      end

      context 'valid schema' do
        let(:raw_contract) do
          expect(schema_generator).to receive(:generate).with(request_file, response_adapter.body, Pacto.configuration.generator_options).and_return response_body_schema
          expect(validator).to receive(:validate).and_return true
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
          expect(generated_request['http_method']).to eq(request.method.downcase.to_s)
        end

        it 'sets the response attributes' do
          generated_response = subject['response']
          expect(generated_response['status']).to eq(response_adapter.status)
        end

        it 'generates pretty JSON' do
          expect(raw_contract).to eq(pretty(subject))
        end
      end

      context 'with hints' do
        let(:raw_contract) do
          expect(schema_generator).to receive(:generate).with(request_file, response_adapter.body, Pacto.configuration.generator_options).and_return response_body_schema
          expect(validator).to receive(:validate).and_return true
          generator.save request_file, request, response_adapter
        end
        subject(:generated_contract) { Pacto::Contract.new(JSON.parse raw_contract) }

        before(:each) do
          # Pacto::Generator.hints do
          #   hint name: 'Foo', method: :get, uri: 'example.com/{asdf}', target_file: '/a/b/c/d/get_foo.json'
          # end
        end

        xit 'names the contract based on the hint' do
          expect(generated_contract.name).to eq('Foo')
        end
      end
    end
  end
end
