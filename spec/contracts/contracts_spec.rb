describe Contracts do
  let(:host) { 'http://localhost' }
  let(:contract_name) { 'contract' }
  let(:contract_path) { File.join('spec', 'data', "#{contract_name}.json") }
  let(:contract) { double('contract') }

  after do
    described_class.unregister_all!
  end

  describe '.register' do
    context 'by default' do
      it 'should register a contract under a given name' do
        described_class.register(contract_name, contract)
        described_class.registered[contract_name].should == contract
      end
    end

    context 'when a contract has already been registered with the same name' do
      it 'should raise an argument error' do
        described_class.register(contract_name, contract)
        expect { described_class.register(contract_name, contract) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.build_from_file' do
    it 'should build a contract given a file path and a host' do
      described_class.build_from_file(contract_path, host).should be_a_kind_of(Contracts::Contract)
    end
  end

  describe '.use' do
    before do
      described_class.register(contract_name, contract)
    end

    context 'by default' do
      let(:instantiated_contract) { double('instantiated contract', :response_body => response_body)}
      let(:response_body) { double('response_body') }

      it 'should instantiate a contract with default values' do
        described_class.registered[contract_name].should_receive(:instantiate).and_return(instantiated_contract)
        instantiated_contract.should_receive(:stub!)
        described_class.use(contract_name).should == response_body
      end
    end

    context 'when contract has not been registered' do
      it 'should raise an argument error' do
        expect { described_class.use('unregistered') }.to raise_error ArgumentError
      end
    end
  end

  describe '.unregister_all!' do
    it 'should unregister all previously registered contracts' do
      described_class.register(contract_name, contract)
      described_class.unregister_all!
      described_class.registered.should be_empty
    end
  end
end
