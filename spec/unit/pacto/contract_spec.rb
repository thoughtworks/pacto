module Pacto
  describe Contract do
    let(:request)  { double 'request' }
    let(:response) { double 'response' }

    let(:contract) { described_class.new request, response }

    describe '#instantiate' do
      before do
        response.stub(:instantiate => instantiated_response)
        InstantiatedContract.stub(:new => instantiated_contract)
      end

      let(:instantiated_response) { double 'instantiated response' }
      let(:instantiated_contract) { double 'instantiated contract' }

      it 'instantiates the response' do
        response.should_receive :instantiate
        contract.instantiate
      end

      it 'creates a new InstantiatedContract' do
        InstantiatedContract.should_receive(:new).
          with(request, instantiated_response).
          and_return(instantiated_contract)
        contract.instantiate
      end

      it 'returns the new instantiated contract' do
        expect(contract.instantiate).to eq instantiated_contract
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
