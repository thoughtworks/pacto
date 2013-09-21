module Pacto
  describe Contract do
    let(:request) { double('request') }
    let(:response) { double('response') }

    let(:contract) { described_class.new(request, response) }

    describe '#instantiate' do
      let(:instantiated_response) { double('instantiated response') }
      let(:instantiated_contract) { double('instantiated contract') }

      it 'should instantiate a contract with default attributes' do
        response.should_receive(:instantiate).and_return(instantiated_response)
        InstantiatedContract.should_receive(:new).
          with(request, instantiated_response).
          and_return(instantiated_contract)
        instantiated_contract.should_not_receive(:replace!)

        contract.instantiate.should == instantiated_contract
      end
    end

    describe '#validate' do
      before do
        response.stub(:validate => validation_result)
        request.stub(:execute => fake_response)
      end

      let(:validation_result) { double 'validation result' }
      let(:fake_response) { double('fake response') }

      it 'validates the generated response' do
        response.should_receive(:validate).with(fake_response, {})
        contract.validate.should == validation_result
      end

      it 'returns the result of the validation' do
        contract.validate.should == validation_result
      end

      it 'generates the response' do
        request.should_receive(:execute)
        contract.validate
      end

      context 'when response gotten is provided' do
        it 'does not generate the response' do
          request.should_not_receive(:execute)
          contract.validate
        end
      end
    end
  end
end
