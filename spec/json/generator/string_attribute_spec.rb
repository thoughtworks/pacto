module JSON
  module Generator
    describe StringAttribute do
      it 'should be a BasicAttribute' do
        described_class.new(nil).should be_kind_of(BasicAttribute)
      end

      describe '#generate' do
        context 'without a default value' do
          it 'should return the default value' do
            described_class.new({'type' => 'string'}).generate.should == 'bar'
          end
        end
      end
    end
  end
end
