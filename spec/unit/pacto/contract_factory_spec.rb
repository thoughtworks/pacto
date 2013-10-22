module Pacto
  describe ContractFactory do
    let(:host)               { 'http://localhost' }
    let(:contract_name)      { 'contract' }
    let(:contracts_path)     { ['spec', 'unit', 'data'] }
    let(:contract_path)      { File.join(contracts_path, "#{contract_name}.json") }
    let(:file_pre_processor) { double('file_pre_processor') }
    let(:file_content)       { File.read(contract_path) }

    describe '.build_from_file' do
      it 'builds a contract given a JSON file path and a host' do
        file_pre_processor.stub(:process).and_return(file_content)
        expect(described_class.build_from_file(contract_path, host, file_pre_processor)).to be_a_kind_of(Pacto::Contract)
      end

      it 'processes files using File Pre Processor module' do
        file_pre_processor.should_receive(:process).with(file_content).and_return(file_content)
        described_class.build_from_file(contract_path, host, file_pre_processor)
      end
    end

    describe '.load' do
      let(:contract) { double :contract }

      it 'builds a contract from a relative path' do
        # TODO: We should not stub a public method of the SUT. This is a smell
        # of this class having more than one responsibility
        Pacto.configuration.should_receive(:contracts_path).and_return contracts_path
        described_class.should_receive(:build_from_file).with(contract_path, host, nil).and_return(contract)
        expect(described_class.load(contract_name, host)).to eq(contract)
      end
    end
  end
end
