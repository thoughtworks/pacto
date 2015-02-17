# -*- encoding : utf-8 -*-
require 'spec_helper'

module Pacto
  module Formats
    module Legacy
      describe ContractFactory do
        let(:host)                 { 'http://localhost' }
        let(:contract_name)        { 'contract' }
        let(:contracts_path)       { %w(spec fixtures contracts) }
        let(:contract_path)        { File.join(contracts_path, "#{contract_name}.json") }
        subject(:contract_factory) { described_class.new }

        it 'builds a Contract given a JSON file path and a host' do
          contract = contract_factory.build_from_file(contract_path, host)
          expect(contract).to be_a(Pacto::Formats::Legacy::Contract)
        end

        context 'deprecated contracts' do
          let(:contracts_path)       { %w(spec fixtures deprecated_contracts) }
          let(:contract_name)        { 'deprecated_contract' }
          it 'can still be loaded' do
            contract = contract_factory.build_from_file(contract_path, host)
            expect(contract).to be_a(Contract)
          end
        end
      end
    end
  end
end
