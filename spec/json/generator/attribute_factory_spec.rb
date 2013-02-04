module JSON
  module Generator
    describe AttributeFactory do
      describe '.create' do
        let(:attribute) { stub('attribute') }

        context 'quando tipo é string' do
          let(:properties) { {'type' => 'string'} }

          it 'should create a StringAttribute' do
            StringAttribute.should_receive(:new).with(properties).and_return(attribute)
            described_class.create(properties).should == attribute
          end
        end

        context 'quando tipo é objeto' do
          let(:properties) { {'type' => 'object'} }

          it 'should create an ObjectAttribute' do
            ObjectAttribute.should_receive(:new).with(properties).and_return(attribute)
            described_class.create(properties).should == attribute
          end
        end

        context 'quando tipo é array' do
          let(:properties) { {'type' => 'array'} }

          it 'deve criar um array' do
            ArrayAttribute.should_receive(:new).with(properties).and_return(attribute)
            described_class.create(properties).should == attribute
          end
        end

        context 'quando tipo é integer' do
          let(:properties) { {'type' => 'integer'} }

          it 'deve criar um integer' do
            IntegerAttribute.should_receive(:new).with(properties).and_return(attribute)
            described_class.create(properties).should == attribute
          end
        end
      end
    end
  end
end
