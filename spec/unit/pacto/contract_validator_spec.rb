module Pacto
  describe ContractValidator do
    let(:validation_errors) { ['some error', 'another error'] }

    let(:expected_response) do
      ResponseClause.new(
        'status' => 200,
        'headers' => {
          'Content-Type' => 'application/json'
        },
        schema: {:type => 'object', :required => true, :properties => double('body definition properties')}
      )
    end

    let(:actual_response) do
      double(
        :status => 200,
        :headers => {'Content-Type' => 'application/json', 'Age' => '60'},
        :body => { 'message' => 'response' }
      )
    end

    let(:actual_request) { double :actual_request }

    let(:expected_request) do
      RequestClause.new(
        host: 'http://example.com',
        schema:  {
          :type => 'object',
          :required => true,
          :properties => double('body definition properties')
        }
      )
    end

    let(:contract) do
      request_pattern_provider = double(for: nil)
      Contract.new(
        request: expected_request,
        response: expected_response,
        file: 'some_file.json',
        name: 'sample',
        request_pattern_provider: request_pattern_provider
      )
    end

    let(:opts) { {} }

    describe '.validate' do
      before do
        allow(Pacto::Validators::RequestBodyValidator).to receive(:validate).with(contract, actual_request).and_return([])
        allow(Pacto::Validators::ResponseBodyValidator).to receive(:validate).with(contract, actual_response).and_return([])
      end

      context 'default validator stack' do
        it 'calls the RequestBodyValidator' do
          expect(Pacto::Validators::RequestBodyValidator).to receive(:validate).with(contract, actual_request).and_return(validation_errors)
          expect(ContractValidator.validate contract, actual_request, actual_response, opts).to eq(validation_errors)
        end

        it 'calls the ResponseStatusValidator' do
          expect(Pacto::Validators::ResponseStatusValidator).to receive(:validate).with(expected_response.status, actual_response.status).and_return(validation_errors)
          expect(ContractValidator.validate contract, actual_request, actual_response, opts).to eq(validation_errors)
        end

        it 'calls the ResponseHeaderValidator' do
          expect(Pacto::Validators::ResponseHeaderValidator).to receive(:validate).with(expected_response.headers, actual_response.headers).and_return(validation_errors)
          expect(ContractValidator.validate contract, actual_request, actual_response, opts).to eq(validation_errors)
        end

        it 'calls the ResponseBodyValidator' do
          expect(Pacto::Validators::ResponseBodyValidator).to receive(:validate).with(contract, actual_response).and_return(validation_errors)
          expect(ContractValidator.validate contract, actual_request, actual_response, opts).to eq(validation_errors)
        end
      end

      context 'when headers and body match and the ResponseStatusValidator reports no errors' do
        it 'does not return any errors' do
          # JSON::Validator.should_receive(:fully_validate).
          #   with(definition['body'], fake_response.body, :version => :draft3).
          #   and_return([])
          expect(Pacto::Validators::RequestBodyValidator).to receive(:validate).with(contract, actual_request).and_return([])
          expect(Pacto::Validators::ResponseStatusValidator).to receive(:validate).with(expected_response.status, actual_response.status).and_return([])
          expect(Pacto::Validators::ResponseHeaderValidator).to receive(:validate).with(expected_response.headers, actual_response.headers).and_return([])
          expect(Pacto::Validators::ResponseBodyValidator).to receive(:validate).with(contract, actual_response).and_return([])
          expect(ContractValidator.validate contract, actual_request, actual_response, opts).to be_empty
        end
      end
    end
  end
end
