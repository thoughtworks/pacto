require_relative '../../../../lib/pacto/core/contract_registry'

module Pacto
  describe ContractRegistry do
    let(:tag) { 'contract_tag' }
    let(:another_tag) { 'another_tag' }
    let(:contract) { sample_contract }
    let(:request_signature) { double('request signature') }

    subject(:contract_registry) do
      ContractRegistry.new
    end

    describe '.register' do
      it 'registers the contract with the default tag' do
        contract_registry.register contract
        expect(contract_registry).to include(contract)
      end
    end

    describe '.contracts_for' do
      before(:each) do
        contract_registry.register contract
      end

      context 'when no contracts are found for a request' do
        it 'returns an empty list' do
          expect(contract).to receive(:matches?).with(request_signature).and_return false
          expect(contract_registry.contracts_for request_signature).to be_empty
        end
      end

      context 'when contracts are found for a request' do
        it 'returns the matching contracts' do
          expect(contract).to receive(:matches?).with(request_signature).and_return true
          expect(contract_registry.contracts_for request_signature).to eq([contract])
        end
      end
    end

    def create_contracts(total, matches)
      total.times.map do
        double('contract',
               :stub_contract! => double('request matcher'),
               :matches? => matches)
      end
    end

    def register_contracts(contracts)
      contracts.each { |contract| contract_registry.register contract }
    end
  end
end
