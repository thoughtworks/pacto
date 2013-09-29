module Pacto
  module Extensions
    describe HashSubsetOf do
      describe '#subset_of?' do
        context 'when the other hash is the same' do
          it 'returns true' do
            {:a => 'a'}.should be_subset_of({:a => 'a'})
          end
        end

        context 'when the other hash is a subset' do
          it 'returns true' do
            {:a => 'a'}.should be_subset_of({:a => 'a', :b => 'b'})
          end
        end

        context 'when the other hash is not a subset' do
          it 'returns false' do
            {:a => 'a'}.subset_of?({:a => 'b'}).should be_false
          end
        end
      end

      describe '#normalize_keys' do
        it 'turns keys into downcased strings' do
          {:A => 'a'}.normalize_keys.should == {'a' => 'a'}
          {:a => 'a'}.normalize_keys.should == {'a' => 'a'}
          {'A' => 'a'}.normalize_keys.should == {'a' => 'a'}
          {'a' => 'a'}.normalize_keys.should == {'a' => 'a'}
        end
      end
    end
  end
end
