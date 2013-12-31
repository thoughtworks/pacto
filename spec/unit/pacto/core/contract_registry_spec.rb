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

    subject(:contract_list) do
      ContractRegistry.new
    end

    describe '.register' do
      context 'no tag' do
        it 'registers the contract with the default tag' do
          contract_list.register_contract contract
          expect(contract_list.registered[:default]).to include(contract)
        end
      end

      context 'one tag' do
        it 'registers a contract under a given tag' do
          contract_list.register_contract(contract, tag)
          expect(contract_list.registered[tag]).to include(contract)
        end

        it 'does not duplicate a contract when it has already been registered with the same tag' do
          contract_list
            .register_contract(contract, tag)
            .register_contract(contract, tag)

          expect(contract_list.registered[tag]).to include(contract)
          expect(contract_list.registered[tag]).to have(1).items
        end
      end

      context 'multiple tags' do
        it 'registers a contract using different tags' do
          contract_list.register_contract(contract, tag, another_tag)
          expect(contract_list.registered[tag]).to include(contract)
          expect(contract_list.registered[another_tag]).to include(contract)
        end

        it 'registers a tag with different contracts ' do
          contract_list
            .register_contract(contract, tag)
            .register_contract(another_contract, tag)

          expect(contract_list.registered[tag]).to include(contract, another_contract)
        end

      end
    end

    describe '.use' do
      before do
        contract_list
          .register_contract(contract, tag)
          .register_contract(another_contract, :default)
      end

      context 'when a contract has been registered' do
        let(:response_body) { double('response_body') }

        it 'stubs a contract with default values' do
          contract.should_receive(:stub_contract!)
          another_contract.should_receive(:stub_contract!)
          contract_list.use(tag)
        end

        it 'stubs default contract if unused tag' do
          another_contract.should_receive(:stub_contract!)
          contract_list.use(another_tag)
        end
      end

      context 'when contract has not been registered' do
        it 'raises an argument error' do
          contract_list = ContractRegistry.new
          expect { contract_list.use('unregistered') }.to raise_error ArgumentError
        end
      end
    end

    describe '.contracts_for' do
      context 'when no contracts are found for a request' do
        it 'returns an empty list' do
          expect(contract_list.contracts_for request_signature).to be_empty
        end
      end

      context 'when contracts are found for a request' do
        it 'returns the matching contracts' do
          register_and_use all_contracts
          expect(contract_list.contracts_for request_signature).to eq(contracts_that_match)
        end
      end
    end

    describe '.contract_for' do
      it 'returns nil if no contracts match' do
        contract_list.should_receive(:contracts_for).with(request_signature).and_return Set.new
        expect(contract_list.contract_for request_signature).to be_nil
      end

      it 'returns the first match if one exists' do
        first = contracts_that_match.first
        matches = Set.new(contracts_that_match)
        contract_list.should_receive(:contracts_for).with(request_signature).and_return matches
        expect(contract_list.contract_for request_signature).to eq(first)
      end
    end

    def create_contracts(total, matches)
      total.times.map do
        double('contract',
               :stub_contract! => double('request matcher'),
               :matches? => matches)
      end
    end

    def register_and_use(contracts)
      contracts.each { |contract| contract_list.register_contract contract }
      contract_list.use :default
    end
  end
end
