module JSON
  module Generator
    describe BasicAttribute do
      describe '#generate' do
        context 'with default value' do
          let(:properties) { {'default' => stub('default')} }

          it 'should return the default value' do
            described_class.new(properties).generate.should == properties['default']
          end
        end
      end

      describe '#required?' do
        context 'when required property is true' do
          let(:properties) { {'required' => true} }

          it 'should be required' do
            described_class.new(properties).should be_required
          end
        end

        context 'when required property is false' do
          let(:properties) { {'required' => false} }

          it 'should not be required' do
            described_class.new(properties).should_not be_required
          end
        end

        context 'when required property is not defined' do
          let(:properties) { {} }

          it 'should not be required' do
            described_class.new(properties).should_not be_required
          end
        end
      end
    end
  end
end
