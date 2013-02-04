describe Contracts do
  let(:contract_name) { 'contract' }
  let(:contract_path) { File.join('spec', 'data', "#{contract_name}.json") }
  let(:contract) { double('contract') }

  describe '.register' do
    it 'should create a new contract and register it' do
      described_class.register(contract_name, contract_path)
      described_class.registered[contract_name].should be_a_kind_of(Contracts::Contract)
    end
  end

  describe '.use' do
    before do
      described_class.register(contract_name, contract_path)
    end

    context 'by default' do
      let(:instantiated_contract) { double('instantiated contract') }

      it 'should instantiate a contract with default values' do
        described_class.registered[contract_name].should_receive(:instantiate).and_return(instantiated_contract)
        instantiated_contract.should_receive(:stub!)
        described_class.use(contract_name)
      end
    end

    context 'when contract has not been registered' do
      it 'should raise an argument error' do
        expect { described_class.use('unregistered') }.to raise_error ArgumentError
      end
    end
  end
end
