module Pacto
  describe Validation do
    let(:request) { double('request') }
    let(:response) { double('response') }
    let(:contract) { Fabricate(:contract) }
    let(:validation_results) { [] }
    let(:validation_results_with_errors) { ['an error occurred'] }

    before(:each) do
      allow(contract).to receive(:validate_response)
    end

    it 'stores the request, response, contract and results' do
      validation = Pacto::Validation.new request, response, contract, validation_results
      expect(validation.request).to eq request
      expect(validation.response).to eq response
      expect(validation.contract).to eq contract
      expect(validation.results).to eq validation_results
    end

    context 'if there were validation errors' do
      subject(:validation) do
        Pacto::Validation.new request, response, contract, validation_results_with_errors
      end

      describe '#successful?' do
        it 'returns false' do
          expect(validation.successful?).to be_false
        end
      end
    end

    context 'if there were no validation errors' do
      subject(:validation) do
        Pacto::Validation.new request, response, contract, validation_results
      end

      it 'returns false' do
        expect(validation.successful?).to be_true
      end
    end

    describe '#against_contract?' do
      it 'returns nil if there was no contract' do
        validation = Pacto::Validation.new request, response, nil, validation_results
        expect(validation.against_contract? 'a').to be_nil
      end

      it 'returns the contract with an exact string name match' do
        allow(contract).to receive(:file).and_return('foo')
        validation = Pacto::Validation.new request, response, contract, validation_results
        expect(validation.against_contract? 'foo').to eq(contract)
        expect(validation.against_contract? 'bar').to be_nil
      end

      it 'returns the contract if there is a regex match' do
        allow(contract).to receive(:file).and_return 'foobar'
        validation = Pacto::Validation.new request, response, contract, validation_results
        expect(validation.against_contract?(/foo/)).to eq(contract)
        expect(validation.against_contract?(/bar/)).to eq(contract)
        expect(validation.against_contract?(/baz/)).to be_nil
      end
    end
  end
end
