require 'spec_helper'
require 'fileutils'

module Pacto
  describe ContractFiles do
    let(:test_dir) { File.join(File.dirname(__FILE__), 'temp') }
    let(:contract_1) { Pathname.new(File.join(test_dir, 'contract_1.json')) }
    let(:contract_2) { Pathname.new(File.join(test_dir, 'contract_2.json')) }
    let(:contract_3) { Pathname.new(File.join(test_dir, 'nested', 'contract_3.json')) }

    before do
      Dir.mkdir(test_dir)
      Dir.chdir(test_dir) do
        Dir.mkdir('nested')
        ['contract_1.json', 'contract_2.json', 'not_a_contract','nested/contract_3.json'].each do |file|
          FileUtils.touch file
        end
      end
    end

    after do
      FileUtils.rm_rf(test_dir)
    end

    describe 'for a dir' do
      it 'returns a list with the full path of all json found recursively in that dir' do
        files = ContractFiles.for(test_dir)
        expect(files.size).to eq(3)
        expect(files).to include(contract_1)
        expect(files).to include(contract_2)
        expect(files).to include(contract_3)
      end
    end

    describe 'for a file' do
      it 'returns a list containing only that file' do
        files = ContractFiles.for(File.join(test_dir, 'contract_1.json'))
        expect(files).to eq [contract_1]
      end
    end
  end
end
