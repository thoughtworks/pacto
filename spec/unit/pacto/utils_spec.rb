module Pacto
  describe Utils do
    describe 'all_json_on' do
      let(:directory) { 'relative/path' }
      let(:files) { double :files }

      before do
        Pacto.configuration.stub(contracts_path: contracts_path)
      end

      context 'when contracts path is configured' do
        let(:contracts_path) { '/contracts/path' }
        let(:expanded_path) { '/contracts/path/relative/path/**/*.json' }

        it 'returns all the json files inside contracts directory' do
          Dir.should_receive(:glob).with(expanded_path).and_return files
          expect(described_class.all_contract_files_on(directory)).to eq files
        end
      end

      context 'when contracts path is not configured' do
        let(:contracts_path) { nil }
        let(:expanded_path) { "#{Dir.pwd}/relative/path/**/*.json" }

        it 'returns all the json files inside directory' do
          Dir.should_receive(:glob).with(expanded_path).and_return files
          expect(described_class.all_contract_files_on(directory)).to eq files
        end
      end
    end
  end
end
