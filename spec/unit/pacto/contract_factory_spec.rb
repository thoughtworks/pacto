require 'spec_helper'

module Pacto
  describe ContractFactory do
    let(:host)                 { 'http://localhost' }
    let(:contract_name)        { 'contract' }
    let(:contracts_path)       { %w(spec fixtures contracts) }
    let(:contract_path)        { File.join(contracts_path, "#{contract_name}.json") }
    let(:contract_files)       { [contract_path, contract_path] }
    subject(:contract_factory) { ContractFactory.new }

    describe '#build' do
      context 'default contract format' do
        it 'builds contracts from a list of file paths and a host' do
          contracts = contract_factory.build(contract_files, host)
          contracts.each do |contract|
            expect(contract).to be_a(Contract)
          end
        end
      end

      context 'custom format' do
        let(:dummy_contract) { double }

        class CustomContractFactory
          def initialize(dummy_contract)
            @dummy_contract = dummy_contract # rubocop:disable RSpec/InstanceVariable
          end

          def build_from_file(_contract_path, _host)
            @dummy_contract # rubocop:disable RSpec/InstanceVariable
          end
        end

        before do
          subject.add_factory :custom, CustomContractFactory.new(dummy_contract)
        end

        it 'delegates to the registered factory' do
          expect(contract_factory.build(contract_files, host, :custom)).to eq([dummy_contract, dummy_contract])
        end
      end

      context 'flattening' do
        let(:contracts_per_file) { 4 }

        class MultiContractFactory
          def initialize(contracts)
            @contracts = contracts # rubocop:disable RSpec/InstanceVariable
          end

          def build_from_file(_contract_path, _host)
            @contracts # rubocop:disable RSpec/InstanceVariable
          end
        end

        before do
          contracts = contracts_per_file.times.map do
            double
          end
          subject.add_factory :multi, MultiContractFactory.new(contracts)
        end

        it 'delegates to the registered factory' do
          loaded_contracts = contract_factory.build(contract_files, host, :multi)
          expected_size = contracts_per_file * contract_files.size
          # If the ContractFactory doesn't flatten returned contracts the size will be off. It needs
          # to flatten because some factories load a single contract per file, others load multiple.
          expect(loaded_contracts.size).to eq(expected_size)
        end
      end
    end
  end
end
