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

end
