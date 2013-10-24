module Pacto
  describe Generator do
    let(:record_host) {
      'http://example.com'
    }
    let(:request) do
      Pacto::Request.new(record_host, {
        'method' => 'GET',
        'path' => '/abcd',
        'headers' => {},
        'params' => []
      })
    end
    let(:response_adapter) do
      Pacto::ResponseAdapter.new(
        OpenStruct.new({
          'status' => 200,
          'headers' => [],
          'body' => double('dummy body')
        })
      )
    end
    let(:response_body_schema) { '{"message": "dummy generated schema"}' }
    let(:version) { 'draft3' }
    let(:schema_generator) { double('schema_generator') }
    let(:validator) { double('validator') }
    let(:request_file) { 'request.json' }
    let(:generator) { described_class.new version, schema_generator, validator }

    describe '#generate' do
      let(:request_contract) {
        double({
          :request => request,
        })
      }
      let(:generated_contract) { double('generated contract') }
      before do
        Pacto.should_receive(:build_from_file).with(request_file, record_host).and_return request_contract
        request.should_receive(:execute).and_return response_adapter
      end

      it 'parses the request' do
        generator.should_receive(:save).with(request, anything)
        generator.generate request_file, record_host
      end

      it 'fetches a response' do
        generator.should_receive(:save).with(anything, response_adapter)
        generator.generate request_file, record_host
      end

      it 'saves the result' do
        generator.should_receive(:save).with(request, response_adapter).and_return generated_contract
        expect(generator.generate request_file, record_host).to eq(generated_contract)
      end
    end

    describe '#save' do
      context 'invalid schema' do
        it 'raises an error if schema generation fails' do
          JSON::SchemaGenerator.should_receive(:generate).and_raise ArgumentError.new('Could not generate schema')
          expect { generator.save request, response_adapter }.to raise_error
        end

        it 'raises an error if the generated contract is invalid' do
          JSON::SchemaGenerator.should_receive(:generate).and_return response_body_schema
          validator.should_receive(:validate).and_raise InvalidContract.new('dummy error')
          expect { generator.save request, response_adapter }.to raise_error
        end
      end

      context 'valid schema' do
        let(:raw_contract) {
          JSON::SchemaGenerator.should_receive(:generate).with('generator', response_adapter.body, 'draft3').and_return response_body_schema
          validator.should_receive(:validate).and_return true
          generator.save request, response_adapter
        }
        subject(:generated_contract) { JSON.parse raw_contract }

        it 'sets the body to the generated json-schema' do
          expect(subject['response']['body']).to eq(JSON.parse response_body_schema)
        end

        it 'sets the request attributes' do
          generated_request = subject['request']
          expect(generated_request['headers']).to eq(request.headers)
          expect(generated_request['params']).to eq(request.params)
          expect(generated_request['path']).to eq(request.path)
        end

        it 'normalizes the request method' do
          generated_request = subject['request']
          expect(generated_request['method']).to eq(request.method.downcase.to_s)
        end

        it 'sets the response attributes' do
          generated_response = subject['response']
          expect(generated_response['headers']).to eq(response_adapter.headers)
          expect(generated_response['status']).to eq(response_adapter.status)
        end

        it 'generates pretty JSON' do
          expect(raw_contract).to eq(JSON.pretty_generate subject)
        end
      end
    end
  end
end
