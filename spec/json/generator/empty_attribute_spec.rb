module JSON
  module Generator
    describe EmptyAttribute do
      it 'should be a BasicAttribute' do
        described_class.new({}).should be_kind_of(BasicAttribute)
      end

      describe '#generate' do
        context 'without a default value' do
          it 'should return nil' do
            described_class.new({}).generate.should be_nil
          end
        end
      end
    end
  end
end
