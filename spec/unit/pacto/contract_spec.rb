module Pacto
  describe Contract do
    let(:request)  { double 'request' }
    let(:response) { double 'response' }

    let(:contract) { described_class.new request, response }
    let(:provider) { double 'provider' }

    describe '#stub!' do
      before do
        response.stub(:instantiate => instantiated_response)
        Pacto.configuration.provider = provider
      end

      let(:instantiated_response) { double 'instantiated response' }

      it 'instantiates the response and registers a stub' do
        response.should_receive :instantiate
        provider.should_receive(:stub!).with request, instantiated_response
        contract.stub!
      end
    end

    describe '#validate' do
      before do
        response.stub(:validate => validation_result)
        request.stub(:execute => fake_response)
      end

      let(:validation_result) { double 'validation result' }
      let(:fake_response)     { double 'fake response' }

      it 'validates the generated response' do
        response.should_receive(:validate).with(fake_response, {})
        expect(contract.validate).to eq validation_result
      end

      it 'returns the result of the validation' do
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
  end
end
