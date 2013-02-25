module Contracts
  describe Contract do
    let(:request) { double('request') }
    let(:response) { double('response') }

    let(:contract) { described_class.new(request, response) }

    describe '#instantiate' do
      let(:instantiated_response) { double('instantiated response') }
      let(:instantiated_contract) { double('instantiated contract') }

      context 'by default' do
        it 'should instantiate a contract with default attributes' do
          response.should_receive(:instantiate).and_return(instantiated_response)
          InstantiatedContract.should_receive(:new).
            with(request, instantiated_response).
            and_return(instantiated_contract)
          instantiated_contract.should_receive(:replace!).with(nil)

          contract.instantiate.should == instantiated_contract
        end
      end

      context 'with extra attributes' do
        let(:attributes) { {:foo => 'bar'} }

        it 'should instantiate a contract and overwrite default attributes' do
          response.should_receive(:instantiate).and_return(instantiated_response)
          InstantiatedContract.should_receive(:new).
            with(request, instantiated_response).
            and_return(instantiated_contract)
          instantiated_contract.should_receive(:replace!).with(attributes)

          contract.instantiate(attributes).should == instantiated_contract
        end
      end
    end

    describe '#validate' do
      let(:fake_response) { double('fake response') }
      let(:validation_result) { double('validation result') }

      it 'should execute the request and match it against the expected response' do
        request.should_receive(:execute).and_return(fake_response)
        response.should_receive(:validate).with(fake_response).and_return(validation_result)
        contract.validate.should == validation_result
      end
    end
  end
end
