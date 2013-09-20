describe Pacto do
  let(:tag) { 'contract_tag' }
  let(:another_tag) { 'another_tag' }
  let(:contract) { double('contract') }
  let(:another_contract) { double('another_contract') }

  after do
    described_class.unregister_all!
  end

  describe '.register' do
    context 'one tag' do
      it 'should register a contract under a given tag' do
        described_class.register(contract, tag)
        expect(described_class.registered[tag]).to include(contract)
      end

      it 'should not duplicate a contract when it has already been registered with the same tag' do
        described_class.register(contract, tag)
        described_class.register(contract, tag)
        expect(described_class.registered[tag]).to include(contract)
        described_class.registered[tag].should have(1).items
      end
    end

    context 'multiple tags' do
      it 'should register a contract using different tags' do
        described_class.register(contract, tag, another_tag)
        expect(described_class.registered[tag]).to include(contract)
        expect(described_class.registered[another_tag]).to include(contract)
      end

      it 'should register a tag with different contracts ' do
        described_class.register(contract, tag)
        described_class.register(another_contract, tag)
        expect(described_class.registered[tag]).to include(contract, another_contract)
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
      described_class.register(contract, tag)
    end

    context 'by default' do
      let(:instantiated_contract) { double('instantiated contract', :response_body => response_body)}
      let(:response_body) { double('response_body') }

      before do
        contract.stub(:instantiate => instantiated_contract)
        instantiated_contract.stub(:stub!)
      end

      it 'should instantiate a contract with default values' do
        contract.should_receive(:instantiate).with(nil).and_return(instantiated_contract)
        described_class.use(tag)
      end

      it 'should return a set including the instantiated contract' do
        expect(described_class.use(tag)).to include(instantiated_contract)
      end

      it 'should stub further requests with the instantiated contract' do
        instantiated_contract.should_receive(:stub!)
        described_class.use(tag)
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
      described_class.register(contract, tag)
      described_class.unregister_all!
      described_class.registered.should be_empty
    end
  end

end
