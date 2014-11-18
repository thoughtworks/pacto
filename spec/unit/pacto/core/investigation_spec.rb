# -*- encoding : utf-8 -*-
module Pacto
  describe Investigation do
    let(:request) { double('request') }
    let(:response) { double('response') }
    let(:contract) { Fabricate(:contract) }
    let(:investigation_citations) { [] }
    let(:investigation_citations_with_errors) { ['an error occurred'] }

    it 'stores the request, response, contract and citations' do
      investigation = Pacto::Investigation.new request, response, contract, investigation_citations
      expect(investigation.request).to eq request
      expect(investigation.response).to eq response
      expect(investigation.contract).to eq contract
      expect(investigation.citations).to eq investigation_citations
    end

    context 'if there were investigation errors' do
      subject(:investigation) do
        Pacto::Investigation.new request, response, contract, investigation_citations_with_errors
      end

      describe '#successful?' do
        it 'returns false' do
          expect(investigation.successful?).to be_falsey
        end
      end
    end

    context 'if there were no investigation errors' do
      subject(:investigation) do
        Pacto::Investigation.new request, response, contract, investigation_citations
      end

      it 'returns false' do
        expect(investigation.successful?).to be true
      end
    end

    describe '#against_contract?' do
      it 'returns nil if there was no contract' do
        investigation = Pacto::Investigation.new request, response, nil, investigation_citations
        expect(investigation.against_contract? 'a').to be_nil
      end

      it 'returns the contract with an exact string name match' do
        allow(contract).to receive(:file).and_return('foo')
        investigation = Pacto::Investigation.new request, response, contract, investigation_citations
        expect(investigation.against_contract? 'foo').to eq(contract)
        expect(investigation.against_contract? 'bar').to be_nil
      end

      it 'returns the contract if there is a regex match' do
        allow(contract).to receive(:file).and_return 'foobar'
        investigation = Pacto::Investigation.new request, response, contract, investigation_citations
        expect(investigation.against_contract?(/foo/)).to eq(contract)
        expect(investigation.against_contract?(/bar/)).to eq(contract)
        expect(investigation.against_contract?(/baz/)).to be_nil
      end
    end
  end
end
