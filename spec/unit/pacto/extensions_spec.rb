module Pacto
  module Extensions
    describe HashSubsetOf do
      describe '#normalize_keys' do
        it 'turns keys into downcased strings' do
          expect({:A => 'a'}.normalize_keys).to eq('a' => 'a')
          expect({:a => 'a'}.normalize_keys).to eq('a' => 'a')
          expect({'A' => 'a'}.normalize_keys).to eq('a' => 'a')
          expect({'a' => 'a'}.normalize_keys).to eq('a' => 'a')
        end
      end

      describe '#normalize_header_keys' do
        it 'matches headers to the style in the RFC documentation' do
          expect(Pacto::Extensions.normalize_header_keys(:'user-agent' => 'a')).to eq('User-Agent' => 'a') # rubocop:disable SymbolName
          expect(Pacto::Extensions.normalize_header_keys(:user_agent => 'a')).to eq('User-Agent' => 'a')
          expect(Pacto::Extensions.normalize_header_keys('User-Agent' => 'a')).to eq('User-Agent' => 'a')
          expect(Pacto::Extensions.normalize_header_keys('user-agent' => 'a')).to eq('User-Agent' => 'a')
          expect(Pacto::Extensions.normalize_header_keys('user_agent' => 'a')).to eq('User-Agent' => 'a')
          expect(Pacto::Extensions.normalize_header_keys('USER_AGENT' => 'a')).to eq('User-Agent' => 'a')
        end
      end
    end
  end
end
