module Pacto
  describe Contract do
    let(:request)  { double 'request' }
    let(:response) { double 'response definition' }
    let(:provider) { double 'provider' }
    let(:file) { 'contranct.json' }
    let(:request_pattern_provider) { double(for: nil) }

    subject(:contract) { Contract.new(request, response, file, 'sample', request_pattern_provider) }

    before do
      Pacto.configuration.provider = provider
    end

    it 'has a request pattern' do
      pattern = double
      expect(request_pattern_provider).to receive(:for).and_return(pattern)
      expect(contract.request_pattern).to eq pattern
    end

    describe '#stub_contract!' do
      it 'register a stub for the contract' do
        provider.should_receive(:stub_request!).with(request, response)
        contract.stub_contract!
      end
    end

    context 'validations' do
      let(:fake_response) { double('fake response') }
      let(:validation_result) { double 'validation result' }

      before do
        allow(Pacto::ContractValidator).to receive(:validate).with(contract, request, fake_response, {}).and_return validation_result
      end

      describe '#validate_consumer' do
        it 'returns the result of the validation' do
          expect(Pacto::ContractValidator).to receive(:validate).with(contract, request, fake_response, {})
          expect(contract.validate_consumer request, fake_response).to eq validation_result
        end

        it 'does not generate another response' do
          request.should_not_receive :execute
          contract.validate_consumer request, fake_response
        end
      end

      describe '#validate_provider' do
        before do
          allow(request).to receive(:execute).and_return fake_response
        end

        it 'generates the response' do
          request.should_receive :execute
          contract.validate_provider
        end

        it 'returns the result of the validating the generated response' do
          expect(Pacto::ContractValidator).to receive(:validate).with(contract, request, fake_response, {})
          expect(contract.validate_provider).to eq validation_result
        end
      end
    end

    describe '#matches?' do
      let(:request_pattern) { double(matches?: true) }
      let(:request_signature)  { double }

      it 'delegates to the request pattern' do
        expect(request_pattern_provider).to receive(:for).and_return(request_pattern)
        expect(request_pattern).to receive(:matches?).with(request_signature)

        contract.matches?(request_signature)
      end
    end
  end
end
