module Pacto
  describe Cops do
    let(:investigation_errors) { ['some error', 'another error'] }

    let(:expected_response) do
      Fabricate(:response_clause)
    end

    let(:actual_response) do
      # TODO: Replace this with a Fabrication for Pacto::PactoResponse (perhaps backed by WebMock)
      Fabricate(:pacto_response)
      # double(
      #   status: 200,
      #   headers: { 'Content-Type' => 'application/json', 'Age' => '60' },
      #   body: { 'message' => 'response' }
      # )
    end

    let(:actual_request) { Fabricate(:pacto_request) }

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
        allow(Pacto::Cops::RequestBodyCop).to receive(:investigate).with(actual_request, actual_response, contract).and_return([])
        allow(Pacto::Cops::ResponseBodyCop).to receive(:investigate).with(actual_request, actual_response, contract).and_return([])
      end

      context 'default cops' do
        let(:investigation) { described_class.perform_investigation actual_request, actual_response, contract }

        it 'calls the RequestBodyCop' do
          expect(Pacto::Cops::RequestBodyCop).to receive(:investigate).with(actual_request, actual_response, contract).and_return(investigation_errors)
          expect(investigation.citations).to eq(investigation_errors)
        end

        it 'calls the ResponseStatusCop' do
          expect(Pacto::Cops::ResponseStatusCop).to receive(:investigate).with(actual_request, actual_response, contract).and_return(investigation_errors)
          expect(investigation.citations).to eq(investigation_errors)
        end

        it 'calls the ResponseHeaderCop' do
          expect(Pacto::Cops::ResponseHeaderCop).to receive(:investigate).with(actual_request, actual_response, contract).and_return(investigation_errors)
          expect(investigation.citations).to eq(investigation_errors)
        end

        it 'calls the ResponseBodyCop' do
          expect(Pacto::Cops::ResponseBodyCop).to receive(:investigate).with(actual_request, actual_response, contract).and_return(investigation_errors)
          expect(investigation.citations).to eq(investigation_errors)
        end
      end

      context 'when headers and body match and the ResponseStatusCop reports no errors' do
        it 'does not return any errors' do
          expect(Pacto::Cops::RequestBodyCop).to receive(:investigate).with(actual_request, actual_response, contract).and_return([])
          expect(Pacto::Cops::ResponseStatusCop).to receive(:investigate).with(actual_request, actual_response, contract).and_return([])
          expect(Pacto::Cops::ResponseHeaderCop).to receive(:investigate).with(actual_request, actual_response, contract).and_return([])
          expect(Pacto::Cops::ResponseBodyCop).to receive(:investigate).with(actual_request, actual_response, contract).and_return([])
          expect(described_class.perform_investigation actual_request, actual_response, contract).to be_successful
        end
      end
    end
  end
end
