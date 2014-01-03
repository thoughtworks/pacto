require 'spec_helper'
require 'fileutils'

module Pacto
  describe ContractFiles do
    let(:test_dir) { File.join(__dir__, 'temp') }
    let(:contract_1) { Pathname.new(File.join(test_dir, 'contract_1.json')) }
    let(:contract_2) { Pathname.new(File.join(test_dir, 'contract_2.json')) }

    before do
      Dir.mkdir(test_dir)
      Dir.chdir(test_dir) do
        ['contract_1.json', 'contract_2.json', 'not_a_contract'].each do |file|
          FileUtils.touch file
        end
      end
    end

    after do
      FileUtils.rm_rf(test_dir)
    end

    describe 'for a dir' do
      it 'returns a list with the full path of all json files in that dir' do
        files = ContractFiles.for(test_dir)
        expect(files).to eq [contract_1, contract_2]
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
