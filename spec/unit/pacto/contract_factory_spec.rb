module Pacto
  describe ContractFactory do
    let(:host)               { 'http://localhost' }
    let(:contract_name)      { 'contract' }
    let(:contracts_path)     { %w(spec unit data) }
    let(:preprocessor)       { double('file_pre_processor') }
    let(:contract_path)      { File.join(contracts_path, "#{contract_name}.json") }
    let(:file_content)       { File.read(contract_path) }

    subject(:contract_factory) { ContractFactory.new(preprocessor: preprocessor) }

    it 'has a default noop processor' do
      factory = ContractFactory.new
      expect(factory.preprocessor).to be_a(NoOpProcessor)
    end

    describe '.build_from_file' do
      it 'builds a contract given a JSON file path and a host' do
        expect(preprocessor).to receive(:process).with(file_content).and_return(file_content)
        contract = contract_factory.build_from_file(contract_path, host)
        expect(contract).to be_a(Contract)
      end
    end
  end
end
