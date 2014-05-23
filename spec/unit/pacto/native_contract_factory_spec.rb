require 'spec_helper'

module Pacto
  describe NativeContractFactory do
    let(:host)                 { 'http://localhost' }
    let(:contract_name)        { 'contract' }
    let(:contracts_path)       { %w(spec unit data) }
    let(:contract_path)        { File.join(contracts_path, "#{contract_name}.json") }
    subject(:contract_factory) { described_class.new }

    it 'builds a contract given a JSON file path and a host' do
      contract = contract_factory.build_from_file(contract_path, host)
      expect(contract).to be_a(Contract)
    end
  end
end
