module Pacto
  describe Generator do
    let(:record_host) do
      'http://example.com'
    end

    let(:request) do
      Faraday::Request.create :get do |req|
        req.path = '/abcd'
        req.params = { 'apikey' => "<%= ENV['MY_API_KEY'] %>" }
        req.headers =  {
          'Content-Length' => [1234],
          'Via' => ['Some Proxy'],
          'User-Agent' => ['rspec']
        }
      end
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
    let(:schema_generator) { double('schema_generator') }
    let(:validator) { double('validator') }
    let(:filters) { double :filters }
    let(:request_file) { 'request.json' }
    let(:options) { Pacto.configuration.generator_options }
    let(:generator) { described_class.new schema_generator, validator, options, filters }

    def pretty(obj)
      MultiJson.encode(obj, :pretty => true).gsub(/^$\n/, '')
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

        it 'sets the body to the generated json-schema' do
          expect(subject['response']['body']).to eq(JSON.parse response_body_schema)
        end

        it 'sets the request attributes' do
          generated_request = subject['request']
          expect(generated_request['params']).to eq(request.params)
          expect(generated_request['path']).to eq(request.path)
        end

        it 'preserves ERB in the request params' do
          generated_request = subject['request']
          expect(generated_request['params']['apikey']).to eq("<%= ENV['MY_API_KEY'] %>")
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
