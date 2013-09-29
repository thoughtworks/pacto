module Pacto
  describe ContractFactory do
    let(:host)               { 'http://localhost' }
    let(:contract_name)      { 'contract' }
    let(:contract_path)      { File.join('spec', 'unit', 'data', "#{contract_name}.json") }
    let(:file_pre_processor) { double('file_pre_processor') }
    let(:file_content)       { File.read(contract_path) }

    describe '.build_from_file' do
      it 'builds a contract given a JSON file path and a host' do
        file_pre_processor.stub(:process).and_return(file_content)
        described_class.build_from_file(contract_path, host, file_pre_processor).
          should be_a_kind_of(Pacto::Contract)
      end

      it 'processes files using File Pre Processor module' do
        file_pre_processor.should_receive(:process).with(file_content).and_return(file_content)
        described_class.build_from_file(contract_path, host, file_pre_processor)
      end
    end
  end
end
