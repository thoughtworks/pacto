module Pacto
  class Generator
    describe Tokenizer do
      let(:contract_source) do
        MultiJson.load(File.read 'spec/unit/data/contract.json')
      end
      let(:token_map) do
        {
          :name => 'Max',
          :company => 'ThoughtWorks'
        }
      end
      subject(:tokenizer) { described_class.new token_map }

      describe '#tokenize_value' do
        it 'replaces values from the token_map with their keys' do
          expect(tokenizer.tokenize_value 'Max').to eq ':name'
        end

        it 'replaces matching substrings with their keys' do
          expect(tokenizer.tokenize_value 'I am Max!').to eq 'I am :name!'
        end

        it 'does not replace other values' do
          expect(tokenizer.tokenize_value 'xaM').to eq 'xaM'
        end
      end

      describe '#tokenize' do
        it 'returns an unmodified contract if there are no tokens to map' do
          contract_double = double('contract json', :empty? => true)
          expect(tokenizer.tokenize contract_double).to eq(contract_double)
        end

        it 'replaces tokens in the path' do
          tokenizer = Tokenizer.new :greeting => 'hello_world'
          tokenized_contract = tokenizer.tokenize contract_source
          expect(tokenized_contract['request']['path']).to eq('/:greeting')
        end

        it 'replaces values with tokens' do
          pending
        end
      end
    end
  end
end
