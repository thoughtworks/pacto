describe Pacto do
  describe '.configure' do
    let(:contracts_path) { 'path_to_contracts' }

    it 'allows contracts_path manual configuration' do
      expect(described_class.configuration.contracts_path).to eq('.')
      described_class.configure do |c|
        c.contracts_path = contracts_path
      end
      expect(described_class.configuration.contracts_path).to eq(contracts_path)
    end

    it 'register a Pacto Hook' do
      hook_block = Pacto::Hook.new {}
      described_class.configure do |c|
        c.register_hook(hook_block)
      end
      expect(described_class.configuration.hook).to eq(hook_block)
    end
  end
end
