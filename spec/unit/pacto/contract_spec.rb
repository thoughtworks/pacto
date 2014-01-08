module Pacto
  describe Contract do
    let(:request)  { double 'request' }
    let(:request_signature)  { double 'request_signature' }
    let(:response) { double 'response definition' }
    let(:provider) { double 'provider' }
    let(:instantiated_response) { double 'instantiated response' }
    let(:file) { 'contranct.json' }
    let(:request_pattern_provider) { double(for: nil) }

    subject(:contract) { Contract.new(request, response, file, request_pattern_provider) }

    before do
      response.stub(:instantiate => instantiated_response)
      Pacto.configuration.provider = provider
    end

    it 'has a request pattern' do
      pattern = double
      expect(request_pattern_provider).to receive(:for).and_return(pattern)
      expect(contract.request_pattern).to eq pattern
    end

    describe '#stub_contract!' do
      it 'instantiates the response and registers a stub' do
        response.should_receive :instantiate
        provider.should_receive(:stub_request!).with request, instantiated_response
        contract.stub_contract!
      end
    end

    describe '#validate' do
      let(:fake_response) { double('fake response') }
      let(:validation_result) { double 'validation result' }

      before do
        allow(Pacto::ContractValidator).to receive(:validate).with(contract, nil, fake_response, {}).and_return validation_result
        allow(request).to receive(:execute).and_return fake_response
      end

      it 'returns the result of the validation' do
        expect(Pacto::ContractValidator).to receive(:validate).with(contract, nil, fake_response, {})
        expect(contract.validate).to eq validation_result
      end

      it 'generates the response' do
        request.should_receive :execute
        contract.validate
      end

      context 'when response gotten is provided' do
        it 'does not generate the response' do
          request.should_not_receive :execute
          contract.validate fake_response
        end
      end
    end

    describe '#matches?' do
      let(:request_matcher) do
        double('fake request matcher').tap do |matcher|
          matcher.stub(:matches?) { |r| r == request_signature }
        end
      end

      context 'when the contract is not stubbed' do
        it 'returns false' do
          expect(contract.matches? request_signature).to be_false
        end
      end

      context 'when the contract is stubbed' do
        it 'returns true if it matches the request' do
          provider.should_receive(:stub_request!).with(request, instantiated_response).and_return(request_matcher)
          contract.stub_contract!
          expect(contract.matches? request_signature).to be_true
          expect(contract.matches? :anything).to be_false
        end
      end
    end
  end
end
