module JSON
  module Generator
    describe AttributeFactory do
      describe '.create' do
        let(:attribute) { stub('attribute') }

        context 'when type is a string' do
          let(:properties) { {'type' => 'string'} }

          it 'should create a StringAttribute' do
            StringAttribute.should_receive(:new).with(properties).and_return(attribute)
            described_class.create(properties).should == attribute
          end
        end

        context 'when type is an object' do
          let(:properties) { {'type' => 'object'} }

          it 'should create an ObjectAttribute' do
            ObjectAttribute.should_receive(:new).with(properties).and_return(attribute)
            described_class.create(properties).should == attribute
          end
        end

        context 'when type is an array' do
          let(:properties) { {'type' => 'array'} }

          it 'should create an ArrayAttribute' do
            ArrayAttribute.should_receive(:new).with(properties).and_return(attribute)
            described_class.create(properties).should == attribute
          end
        end

        context 'when type is an integer' do
          let(:properties) { {'type' => 'integer'} }

          it 'should create an IntegerAttribute' do
            IntegerAttribute.should_receive(:new).with(properties).and_return(attribute)
            described_class.create(properties).should == attribute
          end
        end
      end
    end
  end
end
