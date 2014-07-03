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
    context 'valid' do
      it 'displays a success message and return true' do
        mock_investigation []
        success = described_class.validate_contract 'my_contract.json'
        expect(output).to eq 'Validating my_contract.json'
        expect(success).to be true
      end
    end

    context 'invalid' do
      it 'displays one error messages and return false' do
        mock_investigation ['Error 1']
        success = described_class.validate_contract 'my_contract.json'
        expect(output).to match(/error/)
        expect(success).to be_falsey
      end

      it 'displays several error messages and return false' do
        mock_investigation ['Error 1', 'Error 2']
        success = described_class.validate_contract 'my_contract.json'
        expect(success).to be_falsey
      end
    end
  end

  describe 'loading contracts' do
    let(:contracts_path) { 'path/to/dir' }
    let(:host) { 'localhost' }

    it 'instantiates a contract list' do
      expect(Pacto::ContractList).to receive(:new) do |contracts|
        contracts.each { |contract| expect(contract).to be_a_kind_of(Pacto::Contract) }
      end
      described_class.load_contracts('spec/fixtures/contracts/', host)
    end
  end
end
