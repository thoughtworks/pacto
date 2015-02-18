# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Pacto do
  around(:each) do |example|
    $stdout = StringIO.new
    example.run
    $stdout = STDOUT
  end

  def output
    $stdout.string.strip
  end

  def mock_investigation(errors)
    expect(JSON::Validator).to receive(:fully_validate).with(any_args).and_return errors
  end

  describe '.validate_contract' do
    let(:contract_path) { contract_file 'contract' }

    context 'valid' do
      it 'returns true' do
        mock_investigation []
        success = described_class.validate_contract contract_path
        expect(success).to be true
      end
    end

    context 'invalid' do
      it 'raises an InvalidContract error' do
        mock_investigation ['Error 1']
        expect { described_class.validate_contract contract_path }.to raise_error(Pacto::InvalidContract)
      end
    end
  end

  describe 'loading contracts' do
    let(:contracts_path) { contracts_folder }
    let(:host) { 'localhost' }

    it 'instantiates a contract list' do
      expect(Pacto::ContractSet).to receive(:new) do |contracts|
        contracts.each { |contract| expect(contract).to be_a_kind_of(Pacto::Contract) }
      end
      described_class.load_contracts(contracts_path, host)
    end
  end
end
