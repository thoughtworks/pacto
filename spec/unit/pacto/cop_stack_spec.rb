module Pacto
  describe ValidatorStack do
    let(:validation_errors) { ['some error', 'another error'] }

    let(:expected_response) do
      Fabricate(:response_clause)
    end

    let(:actual_response) do
      # TODO: Replace this with a Fabrication for Pacto::PactoResponse (perhaps backed by WebMock)
      double(
        status: 200,
        headers: { 'Content-Type' => 'application/json', 'Age' => '60' },
        body: { 'message' => 'response' }
      )
    end

    let(:actual_request) { double :actual_request }

    let(:expected_request) do
      Fabricate(:request_clause)
    end

    let(:contract) do
      Fabricate(
        :contract,
        request: expected_request,
        response: expected_response
      )
    end

    describe '#validate_contract' do
      before do
        allow(Pacto::Cops::RequestBodyCop).to receive(:validate).with(actual_request, actual_response, contract).and_return([])
        allow(Pacto::Cops::ResponseBodyCop).to receive(:validate).with(actual_request, actual_response, contract).and_return([])
      end

      context 'default validator stack' do
        let(:validation) { subject.validate_contract actual_request, actual_response, contract }

        it 'calls the RequestBodyCop' do
          expect(Pacto::Cops::RequestBodyCop).to receive(:validate).with(actual_request, actual_response, contract).and_return(validation_errors)
          expect(validation.results).to eq(validation_errors)
        end

        it 'calls the ResponseStatusValidator' do
          expect(Pacto::Cops::ResponseStatusValidator).to receive(:validate).with(actual_request, actual_response, contract).and_return(validation_errors)
          expect(validation.results).to eq(validation_errors)
        end

        it 'calls the ResponseHeaderCop' do
          expect(Pacto::Cops::ResponseHeaderCop).to receive(:validate).with(actual_request, actual_response, contract).and_return(validation_errors)
          expect(validation.results).to eq(validation_errors)
        end

        it 'calls the ResponseBodyCop' do
          expect(Pacto::Cops::ResponseBodyCop).to receive(:validate).with(actual_request, actual_response, contract).and_return(validation_errors)
          expect(validation.results).to eq(validation_errors)
        end
      end

      context 'when headers and body match and the ResponseStatusValidator reports no errors' do
        it 'does not return any errors' do
          # JSON::Validator.should_receive(:fully_validate).
          #   with(definition['body'], fake_response.body, :version => :draft3).
          #   and_return([])
          expect(Pacto::Cops::RequestBodyCop).to receive(:validate).with(actual_request, actual_response, contract).and_return([])
          expect(Pacto::Cops::ResponseStatusValidator).to receive(:validate).with(actual_request, actual_response, contract).and_return([])
          expect(Pacto::Cops::ResponseHeaderCop).to receive(:validate).with(actual_request, actual_response, contract).and_return([])
          expect(Pacto::Cops::ResponseBodyCop).to receive(:validate).with(actual_request, actual_response, contract).and_return([])
          expect(subject.validate_contract actual_request, actual_response, contract).to be_successful
        end
      end
    end
  end
end
