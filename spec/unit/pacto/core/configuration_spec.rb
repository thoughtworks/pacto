describe Pacto do
  describe 'configure' do
    let(:contracts_path) { 'path_to_contracts' }
    it 'allows preprocessor manual configuration' do
      expect(Pacto.configuration.preprocessor).to_not be_nil
      Pacto.configure do |c|
        c.preprocessor = nil
      end
      expect(Pacto.configuration.preprocessor).to be_nil
    end

    it 'allows contracts_path manual configuration' do
      expect(Pacto.configuration.contracts_path).to be_nil
      Pacto.configure do |c|
        c.contracts_path = contracts_path
      end
      expect(Pacto.configuration.contracts_path).to eq(contracts_path)
    end
  end
end
