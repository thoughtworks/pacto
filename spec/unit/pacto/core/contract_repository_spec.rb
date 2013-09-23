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
        described_class.register_contract(contract, tag)
        expect(described_class.registered[tag]).to include(contract)
      end

      it 'should not duplicate a contract when it has already been registered with the same tag' do
        described_class.register_contract(contract, tag)
        described_class.register_contract(contract, tag)
        expect(described_class.registered[tag]).to include(contract)
        described_class.registered[tag].should have(1).items
      end
    end

    context 'multiple tags' do
      it 'should register a contract using different tags' do
        described_class.register_contract(contract, tag, another_tag)
        expect(described_class.registered[tag]).to include(contract)
        expect(described_class.registered[another_tag]).to include(contract)
      end

      it 'should register a tag with different contracts ' do
        described_class.register_contract(contract, tag)
        described_class.register_contract(another_contract, tag)
        expect(described_class.registered[tag]).to include(contract, another_contract)
      end

    end

    context 'with a block' do
      it 'should have a compact syntax for registering multiple contracts' do
        described_class.configure do |c|
          c.register_contract 'new_api/create_item_v2', :item, :new
          c.register_contract 'authentication', :default
          c.register_contract 'list_items_legacy', :legacy
          c.register_contract 'get_item_legacy', :legacy
        end
        expect(described_class.registered[:new]).to include('new_api/create_item_v2')
        expect(described_class.registered[:default]).to include('authentication')
        expect(described_class.registered[:legacy]).to include('list_items_legacy', 'get_item_legacy')
      end
    end
  end

  
  describe '.use' do
    before do
      described_class.register_contract(contract, tag)
    end

    context 'by default' do
      let(:instantiated_contract) { double('instantiated contract', :response_body => response_body)}
      let(:response_body) { double('response_body') }

      before do
        contract.stub(:instantiate => instantiated_contract)
        instantiated_contract.stub(:stub!)
      end

      it 'should instantiate a contract with default values' do
        contract.should_receive(:instantiate).and_return(instantiated_contract)
        described_class.use(tag)
      end

      it 'should return a set including the instantiated contract' do
        expect(described_class.use(tag)).to include(instantiated_contract)
      end

      it 'should stub further requests with the instantiated contract' do
        instantiated_contract.should_receive(:stub!)
        described_class.use(tag)
      end

      it 'should use contracts within the default tag' do
        described_class.register_contract(contract, :default)
        contract.should_receive(:instantiate).and_return(instantiated_contract)
        described_class.use('junk')
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
      described_class.register_contract(contract, tag)
      described_class.unregister_all!
      described_class.registered.should be_empty
    end
  end
  

end