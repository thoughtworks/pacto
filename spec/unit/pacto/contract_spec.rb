module Pacto
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
          instantiated_contract.should_not_receive(:replace!)

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

          contract.instantiate.should == instantiated_contract
        end
      end
    end

    describe '#validate' do
      let(:fake_response) { double('fake response') }
      let(:validation_result) { double('validation result') }

      it 'should execute the request and match it against the expected response' do
        request.should_receive(:execute).and_return(fake_response)
        response.should_receive(:validate).with(fake_response, {}).and_return(validation_result)
        contract.validate.should == validation_result
      end
      
      let(:contract_path) { 'spec/integration/data/simple_contract.json' }
      let(:invalid_response) { {} }
      let(:valid_response) { '{"message": "Hello World!"}' }
    
      it 'should raise argument exception if response is nil' do
        contract = Pacto.build_from_file(contract_path, nil)
        expect {contract.validate(request, nil)}.to raise_error(ArgumentError)
      end
      
      it 'should execute the request and match it against the expected response' do
        contract = Pacto.build_from_file(contract_path, nil)
        contract.validate(nil, invalid_response, body_only: true).should_not be_empty
        contract.validate(nil, valid_response, body_only: true).should be_empty
      end
    end
    
  end
end
