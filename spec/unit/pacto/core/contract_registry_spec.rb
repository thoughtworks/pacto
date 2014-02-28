require_relative '../../../../lib/pacto/core/contract_registry'

module Pacto
  describe ContractRegistry do
    let(:tag) { 'contract_tag' }
    let(:another_tag) { 'another_tag' }
    let(:contract) { double('contract') }
    let(:contract_factory)  { double }
    let(:another_contract) { double('another_contract') }
    let(:request_signature) { double('request signature') }
    let(:contracts_that_match)      { create_contracts 2, true }
    let(:contracts_that_dont_match) { create_contracts 3, false }
    let(:all_contracts)             { contracts_that_match + contracts_that_dont_match }

    subject(:contract_registry) do
      ContractRegistry.new
    end

    describe '.register' do
      context 'no tag' do
        it 'registers the contract with the default tag' do
          contract_registry.register contract
          expect(contract_registry[:default]).to include(contract)
        end
      end

      context 'one tag' do
        it 'registers a contract under a given tag' do
          contract_registry.register(contract, tag)
          expect(contract_registry[tag]).to include(contract)
        end

        it 'does not duplicate a contract when it has already been registered with the same tag' do
          contract_registry
            .register(contract, tag)
            .register(contract, tag)

          expect(contract_registry[tag]).to include(contract)
          expect(contract_registry[tag]).to have(1).items
        end
      end

      context 'multiple tags' do
        it 'registers a contract using different tags' do
          contract_registry.register(contract, tag, another_tag)
          expect(contract_registry[tag]).to include(contract)
          expect(contract_registry[another_tag]).to include(contract)
        end

        it 'registers a tag with different contracts ' do
          contract_registry
            .register(contract, tag)
            .register(another_contract, tag)

          expect(contract_registry[tag]).to include(contract, another_contract)
        end

      end
    end

    describe '.contracts_for' do
      context 'when no contracts are found for a request' do
        it 'returns an empty list' do
          expect(contract_registry.contracts_for request_signature).to be_empty
        end
      end

      context 'when contracts are found for a request' do
        it 'returns the matching contracts' do
          register_contracts all_contracts
          expect(contract_registry.contracts_for request_signature).to eq(contracts_that_match)
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
