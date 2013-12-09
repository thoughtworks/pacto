module Pacto
  describe Response do
    let(:body_definition) do
      {:type => 'object', :required => true, :properties => double('body definition properties')}
    end
    let(:definition) do
      {
        'status' => 200,
        'headers' => {
          'Content-Type' => 'application/json'
        },
        'body' => body_definition
      }
    end
    subject(:response) { described_class.new(definition) }

    describe '#instantiate' do
      let(:generated_body) { double('generated body') }

      it 'instantiates a response with a body that matches the given definition' do
        JSON::Generator.should_receive(:generate).
          with(definition['body']).
          and_return(generated_body)

        instantiated_response = response.instantiate
        expect(instantiated_response.status).to eq definition['status']
        expect(instantiated_response.headers).to eq definition['headers']
        expect(instantiated_response.body).to eq generated_body
      end
    end

    describe '#validate' do
      let(:status) { 200 }
      let(:headers) { {'Content-Type' => 'application/json', 'Age' => '60'} }
      let(:response_body) { {'message' => 'response'} }
      let(:fake_response) do
        double(
          :status => status,
          :headers => headers,
          :body => response_body
        )
      end

      context 'default validator stack' do
        it 'calls the ResponseStatusValidator' do
          validation_error = double('some error')

          expect(Pacto::Validators::ResponseStatusValidator).to receive(:validate).with(status, fake_response.status).and_return(validation_error)
          expect(response.validate fake_response).to eq(validation_error)
        end
      end

      context 'when headers and body match and the ResponseStatusValidator reports no errors' do
        it 'does not return any errors' do
          JSON::Validator.should_receive(:fully_validate).
            with(definition['body'], fake_response.body, :version => :draft3).
            and_return([])
          expect(Pacto::Validators::ResponseStatusValidator).to receive(:validate).with(status, fake_response.status).and_return(nil)

          expect(response.validate(fake_response)).to be_empty
        end
      end

      context 'when body is a pure string and matches the description' do
        let(:string_required) { true }
        let(:body_definition) do
          { 'type' => 'string', 'required' => string_required }
        end
        let(:response_body) { 'a simple string' }

        it 'does not validate using JSON Schema' do

          JSON::Validator.should_not_receive(:fully_validate)
          response.validate(fake_response)
        end

        context 'if required' do
          it 'does not return an error when body is a string' do

            expect(response.validate(fake_response)).to be_empty
          end

          it 'returns an error when body is nil' do

            fake_response.stub(:body).and_return(nil)
            expect(response.validate(fake_response).size).to eq 1
          end
        end

        context 'if not required' do
          let(:string_required) { false }

          it 'does not return an error when body is a string' do

            expect(response.validate(fake_response)).to be_empty
          end

          it 'does not return an error when body is nil' do

            fake_response.stub(:body).and_return(nil)
            expect(response.validate(fake_response)).to be_empty
          end
        end

        context 'if contains pattern' do
          let(:body_definition) do
            { 'type' => 'string', 'required' => string_required, 'pattern' => 'a.c' }
          end

          context 'body matches pattern' do
            let(:response_body) { 'cabcd' }

            it 'does not return an error' do
              expect(response.validate(fake_response)).to be_empty
            end
          end

          context 'body does not match pattern' do
            let(:response_body) { 'cabscd' }

            it 'returns an error' do
              expect(response.validate(fake_response).size).to eq 1
            end
          end

        end
      end

      context 'when headers do not match' do
        let(:headers) { {'Content-Type' => 'text/html'} }

        it 'returns a header error' do
          JSON::Validator.should_not_receive(:fully_validate)

          expect(response.validate(fake_response)).to eq ["Invalid headers: expected #{definition['headers'].inspect} to be a subset of #{headers.inspect}"]
        end
      end

      context 'when Location Header is expected' do
        before(:each) do
          definition['headers'].merge!('Location' => 'http://www.example.com/{foo}/bar')
        end

        context 'and no Location header is sent' do
          it 'returns a header error when no Location header is sent' do
            JSON::Validator.should_not_receive(:fully_validate)

            expect(response.validate(fake_response)).to eq ['Expected a Location Header in the response']
          end
        end

        context 'but the Location header does not matches the pattern' do
          let(:headers) do
            {
              'Content-Type' => 'application/json',
              'Location' => 'http://www.example.com/foo/bar/baz'
            }
          end

          it 'returns a validation error' do
            JSON::Validator.should_not_receive(:fully_validate)

            expect(response.validate(fake_response)).to eq ["Location mismatch: expected URI #{headers['Location']} to match URI Template #{definition['headers']['Location']}"]
          end
        end

        context 'and the Location header matches pattern' do
          let(:headers) do
            {
              'Content-Type' => 'application/json',
              'Location' => 'http://www.example.com/foo/bar'
            }
          end

          it 'validates successfully' do
            JSON::Validator.stub(:fully_validate).and_return([])

            expect(response.validate(fake_response)).to be_empty
          end
        end
      end

      context 'when headers are a subset of expected headers' do
        let(:headers) { {'Content-Type' => 'application/json'} }

        it 'does not return any errors' do
          JSON::Validator.stub(:fully_validate).and_return([])

          expect(response.validate(fake_response)).to be_empty
        end
      end

      context 'when headers values match but keys have different case' do
        let(:headers) { {'content-type' => 'application/json'} }

        it 'does not return any errors' do
          JSON::Validator.stub(:fully_validate).and_return([])

          expect(response.validate(fake_response)).to be_empty
        end
      end

      context 'when body does not match' do
        let(:errors) { [double('error1'), double('error2')] }

        it 'returns a list of errors' do
          JSON::Validator.stub(:fully_validate).and_return(errors)

          expect(response.validate(fake_response)).to eq errors
        end
      end

      context 'when body not specified' do
        let(:definition) do
          {
            'status' => status,
            'headers' => headers
          }
        end

        it 'does not validate body' do
          JSON::Validator.should_not_receive(:fully_validate)
        end

        it 'gives no errors' do
          expect(response.validate(fake_response)).to be_empty
        end
      end
    end
  end
end
