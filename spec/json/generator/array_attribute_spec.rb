module JSON
  module Generator
    describe ArrayAttribute do
      it 'should be a BasicAttribute' do
        described_class.new(nil).should be_a_kind_of(BasicAttribute)
      end

      describe '#generate' do
        context 'with minItems' do
          it 'should generate an array with two objects of the expected type' do
            stubbed_item = stub('item', :generate => 'foo')
            AttributeFactory.should_receive(:create).twice.
              with('type' => 'dummy_type').
              and_return(stubbed_item)

            properties = {
              'type' => 'array',
              'minItems' => 2,
              'items' => {
                'type' => 'dummy_type'
              }
            }
            described_class.new(properties).generate.should ==
              [stubbed_item.generate, stubbed_item.generate]
          end
        end

        context 'without minItems' do
          it 'should generate an empty array' do
            properties = {
              'type' => 'array',
              'items' => {
                'type' => 'dummy_type'
              }
            }
            described_class.new(properties).generate.should == []
          end
        end
      end
    end
  end
end
