module Contracts
  describe Contract do
    describe '#instantiate' do
      let(:request) { double('request') }
      let(:response) { double('response') }
      let(:instantiated_response) { double('instantiated response') }
      let(:instantiated_contract) { double('instantiated contract') }

      let(:contract) { described_class.new(request, response) }

      context 'by default' do
        it 'should instantiate a contract with default attributes' do
          response.should_receive(:instantiate).and_return(instantiated_response)
          InstantiatedContract.should_receive(:new).
            with(request, instantiated_response).
            and_return(instantiated_contract)
          instantiated_contract.should_receive(:replace!).with({})

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
  end
end
