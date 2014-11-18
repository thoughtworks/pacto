# -*- encoding : utf-8 -*-
require 'spec_helper'

module Pacto
  describe ContractSet do
    let(:contract1) { Fabricate(:contract) }
    let(:contract2) { Fabricate(:contract, request: Fabricate(:request_clause, host: 'www2.example.com')) }

    it 'holds a list of contracts' do
      list = ContractSet.new([contract1, contract2])
      expect(list).to eq(Set.new([contract1, contract2]))
    end

    context 'when validating' do
      it 'validates every contract on the list' do
        expect(contract1).to receive(:simulate_request)
        expect(contract2).to receive(:simulate_request)

        list = ContractSet.new([contract1, contract2])
        list.simulate_consumers
      end
    end

    context 'when stubbing' do
      let(:values) { Hash.new }

      it 'stubs every contract on the list' do
        expect(contract1).to receive(:stub_contract!).with(values)
        expect(contract2).to receive(:stub_contract!).with(values)

        list = ContractSet.new([contract1, contract2])
        list.stub_providers(values)
      end
    end
  end
end
