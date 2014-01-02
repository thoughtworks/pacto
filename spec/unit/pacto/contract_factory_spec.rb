require 'spec_helper'

module Pacto
  describe ContractFactory do
    let(:host)                 { 'http://localhost' }
    let(:contract_name)        { 'contract' }
    let(:contracts_path)       { %w(spec unit data) }
    let(:contract_path)        { File.join(contracts_path, "#{contract_name}.json") }
    subject(:contract_factory) { ContractFactory.new }

    it 'builds a contract given a JSON file path and a host' do
      contract = contract_factory.build_from_file(contract_path, host)
      expect(contract).to be_a(Contract)
    end

    it 'builds contracts from a list of file paths and a host' do
      contract_files = [contract_path, contract_path]
      contracts = contract_factory.build(contract_files, host)
      contracts.each do |contract|
        expect(contract).to be_a(Contract)
      end
    end
  end
end
