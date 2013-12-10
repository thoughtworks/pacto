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

        it 'calls the ResponseHeaderValidator' do
          validation_error = double('some error')

          expect(Pacto::Validators::ResponseHeaderValidator).to receive(:validate).with(definition['headers'], fake_response.headers).and_return(validation_error)
          expect(response.validate fake_response).to eq(validation_error)
        end

        it 'calls the ResponseBodyValidator' do
          validation_error = double('some error')

          expect(Pacto::Validators::ResponseBodyValidator).to receive(:validate).with(body_definition, fake_response).and_return(validation_error)
          expect(response.validate fake_response).to eq(validation_error)
        end
      end

      context 'when headers and body match and the ResponseStatusValidator reports no errors' do
        it 'does not return any errors' do
          # JSON::Validator.should_receive(:fully_validate).
          #   with(definition['body'], fake_response.body, :version => :draft3).
          #   and_return([])
          expect(Pacto::Validators::ResponseStatusValidator).to receive(:validate).with(status, fake_response.status).and_return(nil)
          expect(Pacto::Validators::ResponseHeaderValidator).to receive(:validate).with(definition['headers'], fake_response.headers).and_return(nil)
          expect(Pacto::Validators::ResponseBodyValidator).to receive(:validate).with(body_definition, fake_response).and_return([])

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
