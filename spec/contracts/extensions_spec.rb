module Contracts
  module Extensions
    describe HashSubsetOf do
      describe '#subset_of?' do
        context 'when the other hash is the same' do
          it 'should return true' do
            {:a => 'a'}.should be_subset_of({:a => 'a'})
          end
        end

        context 'when the other hash is a subset' do
          it 'should return true' do
            {:a => 'a'}.should be_subset_of({:a => 'a', :b => 'b'})
          end
        end

        context 'when the other hash is not a subset' do
          it 'should return false' do
            {:a => 'a'}.subset_of?({:a => 'b'}).should be_false
          end
        end
      end
    end
  end
end
