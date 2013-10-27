module Pacto
  describe Utils do
    describe 'all_json_on' do
      let(:expanded_path) { '/contracts/path/relative/path/**.json' }
      let(:directory) { 'relative/path' }
      let(:contracts_path) { '/contracts/path' }
      let(:files) { %w(file1 file2) }

      before do
        Pacto.configuration.stub(contracts_path: contracts_path)
        File.stub(expand_path: expanded_path)
        Dir.stub(glob: files)
      end

      it 'expands the path on contracts directory' do
        File.should_receive(:expand_path).with('**.json', directory, contracts_path).and_return expanded_path
        described_class.all_contract_files_on(directory)
      end

      context 'when contracts path does not exist' do
        let(:contracts_path) { nil }

        it 'expands the path on the current working directory' do
          File.should_receive(:expand_path).with('**.json', directory).and_return expanded_path
          described_class.all_contract_files_on directory
        end
      end

      it 'returns all the json files on the expanded path' do
        Dir.should_receive(:glob).with(expanded_path).and_return files
        expect(described_class.all_contract_files_on(directory)).to eq files
      end
    end
  end
end
