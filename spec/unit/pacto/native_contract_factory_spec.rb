require 'spec_helper'

module Pacto
  describe NativeContractFactory do
    let(:host)                 { 'http://localhost' }
    let(:contract_name)        { 'contract' }
    let(:contracts_path)       { %w(spec fixtures contracts) }
    let(:contract_path)        { File.join(contracts_path, "#{contract_name}.json") }
    subject(:contract_factory) { described_class.new }

    it 'builds a contract given a JSON file path and a host' do
      contract = contract_factory.build_from_file(contract_path, host)
      expect(contract).to be_a(Contract)
    end

    context 'contract template ends with .erb' do
      let(:contract_path) { File.join(contracts_path, "#{contract_name}.json.erb") }

      it 'builds the contract' do
        contract = contract_factory.build_from_file(contract_path, host)
        expect(contract).to be_a(Contract)
      end
    end

    context 'contract template does not end with .erb' do
      let(:contract_name) { 'templating_contract' }

      it 'builds the contract' do
        contract = contract_factory.build_from_file(contract_path, host)
        expect(contract).to be_a(Contract)
      end
    end

    context 'deprecated contracts' do
      let(:contracts_path)       { %w(spec fixtures deprecated_contracts) }
      let(:contract_name)        { 'deprecated_contract' }
      it 'can still be loaded' do
        contract = contract_factory.build_from_file(contract_path, host)
        expect(contract).to be_a(Contract)
      end
    end

    describe '#files_for' do
      context 'given directory' do
        let(:contract_path) { File.join(contracts_path) }

        it 'includes .json files' do
          files = contract_factory.files_for(contract_path).collect { |f| f.basename.to_s }
          expect(files).to include('contract.json')
        end

        it 'includes .json.erb files' do
          files = contract_factory.files_for(contract_path).collect { |f| f.basename.to_s }
          expect(files).to include('contract.json.erb')
        end
      end
    end
  end
end
