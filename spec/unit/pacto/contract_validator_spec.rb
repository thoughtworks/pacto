module Pacto
  describe ContractValidator do
    let(:validation_errors) { ['some error', 'another error'] }

    let(:expected_response) do
      Pacto::Response.new(
        'status' => 200,
        'headers' => {
          'Content-Type' => 'application/json'
        },
        'body' =>  {:type => 'object', :required => true, :properties => double('body definition properties')}
      )
    end

    let(:actual_response) do
      double(
        :status => 200,
        :headers => {'Content-Type' => 'application/json', 'Age' => '60'},
        :body => { 'message' => 'response' }
      )
    end

    let(:contract) do
      Contract.new(nil, expected_response, 'some_file.json')
    end

    let(:opts) do
      {}
    end

    describe '.validate' do
      before do
        allow(Pacto::Validators::ResponseBodyValidator).to receive(:validate).with(expected_response.schema, actual_response).and_return([])
      end

      context 'default validator stack' do
        it 'calls the ResponseStatusValidator' do
          expect(Pacto::Validators::ResponseStatusValidator).to receive(:validate).with(expected_response.status, actual_response.status).and_return(validation_errors)
          expect(ContractValidator.validate contract, nil, actual_response, opts).to eq(validation_errors)
        end

        it 'calls the ResponseHeaderValidator' do
          expect(Pacto::Validators::ResponseHeaderValidator).to receive(:validate).with(expected_response.headers, actual_response.headers).and_return(validation_errors)
          expect(ContractValidator.validate contract, nil, actual_response, opts).to eq(validation_errors)
        end

        it 'calls the ResponseBodyValidator' do
          expect(Pacto::Validators::ResponseBodyValidator).to receive(:validate).with(expected_response.schema, actual_response).and_return(validation_errors)
          expect(ContractValidator.validate contract, nil, actual_response, opts).to eq(validation_errors)
        end
      end

      context 'when headers and body match and the ResponseStatusValidator reports no errors' do
        it 'does not return any errors' do
          # JSON::Validator.should_receive(:fully_validate).
          #   with(definition['body'], fake_response.body, :version => :draft3).
          #   and_return([])
          expect(Pacto::Validators::ResponseStatusValidator).to receive(:validate).with(expected_response.status, actual_response.status).and_return([])
          expect(Pacto::Validators::ResponseHeaderValidator).to receive(:validate).with(expected_response.headers, actual_response.headers).and_return([])
          expect(Pacto::Validators::ResponseBodyValidator).to receive(:validate).with(expected_response.schema, actual_response).and_return([])
          expect(ContractValidator.validate contract, nil, actual_response, opts).to be_empty
        end
      end
    end
  end
end
