module Pacto
  describe Validation do
    let(:request) { double('request') }
    let(:response) { double('response') }
    let(:contract) { Fabricate(:contract) }
    let(:validation_citations) { [] }
    let(:validation_citations_with_errors) { ['an error occurred'] }

    it 'stores the request, response, contract and citations' do
      validation = Pacto::Validation.new request, response, contract, validation_citations
      expect(validation.request).to eq request
      expect(validation.response).to eq response
      expect(validation.contract).to eq contract
      expect(validation.citations).to eq validation_citations
    end

    context 'if there were validation errors' do
      subject(:validation) do
        Pacto::Validation.new request, response, contract, validation_citations_with_errors
      end

      describe '#successful?' do
        it 'returns false' do
          expect(validation.successful?).to be_falsey
        end
      end
    end

    context 'if there were no validation errors' do
      subject(:validation) do
        Pacto::Validation.new request, response, contract, validation_citations
      end

      it 'returns false' do
        expect(validation.successful?).to be true
      end
    end

    describe '#against_contract?' do
      it 'returns nil if there was no contract' do
        validation = Pacto::Validation.new request, response, nil, validation_citations
        expect(validation.against_contract? 'a').to be_nil
      end

      it 'returns the contract with an exact string name match' do
        allow(contract).to receive(:file).and_return('foo')
        validation = Pacto::Validation.new request, response, contract, validation_citations
        expect(validation.against_contract? 'foo').to eq(contract)
        expect(validation.against_contract? 'bar').to be_nil
      end

      it 'returns the contract if there is a regex match' do
        allow(contract).to receive(:file).and_return 'foobar'
        validation = Pacto::Validation.new request, response, contract, validation_citations
        expect(validation.against_contract?(/foo/)).to eq(contract)
        expect(validation.against_contract?(/bar/)).to eq(contract)
        expect(validation.against_contract?(/baz/)).to be_nil
      end
    end
  end
end
