# -*- encoding : utf-8 -*-
require 'spec_helper'

module Pacto
  module Formats
    module Legacy
      describe ContractFactory do
        let(:host)                 { 'http://localhost' }
        let(:contract_format)      { 'legacy' }
        let(:contract_name)        { 'contract' }
        let(:contract_path)        { contract_file(contract_name, contract_format) }
        subject(:contract_factory) { described_class.new }

        it 'builds a Contract given a JSON file path and a host' do
          contract = contract_factory.build_from_file(contract_path, host)
          expect(contract).to be_a(Pacto::Formats::Legacy::Contract)
        end

        context 'deprecated contracts' do
          let(:contract_format)      { 'deprecated' }
          let(:contract_name)        { 'deprecated_contract' }
          it 'can no longer be loaded' do
            expect { contract_factory.build_from_file(contract_path, host) }.to raise_error(/old syntax no longer supported/)
          end
        end
      end
    end
  end
end
