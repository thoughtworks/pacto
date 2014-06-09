require 'spec_helper'

module Pacto
  describe ContractList do
    let(:contract1) { Fabricate(:contract) }
    let(:contract2) { Fabricate(:contract, request: Fabricate(:request_clause, host: 'www2.example.com')) }

    it 'holds a list of contracts' do
      list = ContractList.new([contract1, contract2])
      expect(list.contracts).to eq([contract1, contract2])
    end

    context 'when validating' do
      it 'validates every contract on the list' do
        expect(contract1).to receive(:simulate_request)
        expect(contract2).to receive(:simulate_request)

        list = ContractList.new([contract1, contract2])
        list.validate_all
      end
    end

    context 'when stubbing' do
      let(:values) { Hash.new }

      it 'stubs every contract on the list' do
        expect(contract1).to receive(:stub_contract!).with(values)
        expect(contract2).to receive(:stub_contract!).with(values)

        list = ContractList.new([contract1, contract2])
        list.stub_all(values)
      end
    end
  end
end
