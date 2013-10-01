module Pacto
  module Extensions
    describe HashSubsetOf do
      describe '#subset_of?' do
        context 'when the other hash is the same' do
          it 'returns true' do
            expect({:a => 'a'}).to be_subset_of({:a => 'a'})
          end
        end

        context 'when the other hash is a subset' do
          it 'returns true' do
            expect({:a => 'a'}).to be_subset_of({:a => 'a', :b => 'b'})
          end
        end

        context 'when the other hash is not a subset' do
          it 'returns false' do
            expect({:a => 'a'}.subset_of?({:a => 'b'})).to be_false
          end
        end
      end

      describe '#normalize_keys' do
        it 'turns keys into downcased strings' do
          expect({:A => 'a'}.normalize_keys).to eq({'a' => 'a'})
          expect({:a => 'a'}.normalize_keys).to eq({'a' => 'a'})
          expect({'A' => 'a'}.normalize_keys).to eq({'a' => 'a'})
          expect({'a' => 'a'}.normalize_keys).to eq({'a' => 'a'})
        end
      end
    end
  end
end
