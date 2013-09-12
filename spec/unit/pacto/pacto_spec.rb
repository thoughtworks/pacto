describe Pacto do
  let(:contract_name) { 'contract' }
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
    let(:path)                  { 'contract/path' }
    let(:host)                  { 'http://localhost' }
    let(:file_pre_processor)    { double('file_pre_processor') }
    let(:instantiated_contract) { double(:instantiated_contract) }

    it 'delegates to ContractFactory' do
      Pacto::ContractFactory.should_receive(:build_from_file).with(path, host, file_pre_processor)
      described_class.build_from_file(path, host, file_pre_processor)
    end

    it 'returns whatever the factory returns' do
      Pacto::ContractFactory.stub(:build_from_file => instantiated_contract)
      described_class.build_from_file(path, host, file_pre_processor).should == instantiated_contract
    end
  end

  describe '.use' do
    before do
      described_class.register(contract_name, contract)
    end

    context 'by default' do
      let(:instantiated_contract) { double('instantiated contract', :response_body => response_body)}
      let(:response_body) { double('response_body') }

      before do
        described_class.registered[contract_name].stub(:instantiate => instantiated_contract)
        instantiated_contract.stub(:stub!)
      end

      it 'should instantiate a contract with default values' do
        described_class.registered[contract_name].should_receive(:instantiate).and_return(instantiated_contract)
        described_class.use(contract_name)
      end

      it 'should return the instantiated contract' do
        described_class.use(contract_name).should == instantiated_contract
      end

      it 'should stub further requests with the instantiated contract' do
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

  describe '.unregister_all!' do
    it 'should unregister all previously registered contracts' do
      described_class.register(contract_name, contract)
      described_class.unregister_all!
      described_class.registered.should be_empty
    end
  end
  
  describe "configure" do
    it 'should allow preprocessor manual configuration' do
      Pacto.configuration.preprocessor.should_not be_nil
      Pacto.configure do |c|
        c.preprocessor = nil
      end
      Pacto.configuration.preprocessor.should be_nil
    end
  end
end
