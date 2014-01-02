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

  def mock_validation(errors)
    expect(JSON::Validator).to receive(:fully_validate).with(any_args).and_return errors
  end

  describe '.validate_contract' do
    context 'valid' do
      it 'displays a success message and return true' do
        mock_validation []
        success = Pacto.validate_contract 'my_contract.json'
        expect(output).to eq 'Validating my_contract.json'
        expect(success).to be_true
      end
    end

    context 'invalid' do
      it 'displays one error messages and return false' do
        mock_validation ['Error 1']
        success = Pacto.validate_contract 'my_contract.json'
        expect(output).to match /error/
        expect(success).to be_false
      end

      it 'displays several error messages and return false' do
        mock_validation ['Error 1', 'Error 2']
        success = Pacto.validate_contract 'my_contract.json'
        expect(success).to be_false
      end
    end
  end

  describe '.build_from_file' do
    let(:path)                  { 'contract/path' }
    let(:host)                  { 'http://localhost' }
    let(:instantiated_contract) { double(:instantiated_contract) }
    let(:factory)               { double(:factory) }

    before do
      allow(Pacto::ContractFactory).to receive(:new).and_return(factory)
    end

    it 'delegates to ContractFactory' do
      expect(factory).to receive(:build_from_file).
        with(path, host).
        and_return(instantiated_contract)

      contract = Pacto.build_from_file(path, host)
      expect(contract).to eq instantiated_contract
    end
  end
end
