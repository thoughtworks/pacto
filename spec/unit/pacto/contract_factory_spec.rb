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

      pending 'parses the contract definition'
      pending 'validates the definition against an schema'
      pending 'build a contract based on the request, respons and path'
    end

    describe '.load' do
      let(:contract) { double :contract }

      it 'builds a contract from a relative path' do
        # TODO: We should not stub a public method of the SUT. This is a smell
        # of this class having more than one responsibility
        Pacto.configuration.should_receive(:contracts_path).and_return contracts_path
        contract_factory.should_receive(:build_from_file).with(contract_path, host).and_return(contract)
        expect(contract_factory.load(contract_name, host)).to eq(contract)
      end
    end
  end
end
