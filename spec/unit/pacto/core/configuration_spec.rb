describe Pacto do
  describe 'configure' do
    let(:contracts_path) { 'path_to_contracts' }
    it 'allows preprocessor manual configuration' do
      Pacto.configuration.preprocessor.should_not be_nil
      Pacto.configure do |c|
        c.preprocessor = nil
      end
      Pacto.configuration.preprocessor.should be_nil
    end

    it 'allows contracts_path manual configuration' do
      Pacto.configuration.contracts_path.should be_nil
      Pacto.configure do |c|
        c.contracts_path = contracts_path
      end
      Pacto.configuration.contracts_path.should eql(contracts_path)
    end
  end
end
