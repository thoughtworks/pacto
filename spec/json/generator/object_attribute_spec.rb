module JSON
	module Generator
		describe ObjectAttribute do
			describe '#generate' do
				context 'when not required' do
					let(:attributes) { {'type' => 'object', 'properties' => {}} }

					it 'should return nil' do
						described_class.new(attributes).generate.should be_nil
					end
				end

				context 'without properties' do
					let(:attributes) { {'type' => 'object', 'required' => true} }

					it 'should generate an empty object' do
						described_class.new(attributes).generate.should == {}
					end
				end

				context 'with empty properties' do
					let(:attributes) do
						{
							'type' => 'object',
							'properties' => {},
							'required' => true
						}
					end

					it 'should generate an empty object' do
						described_class.new(attributes).generate.should == {}
					end
				end

				context 'with one property' do
					let(:attributes) do
						{
							'type' => 'object',
							'properties' => {
								'foo' => property_attributes
							},
							'required' => true
						}
					end
					let(:property_attributes) { double('property attributes') }
					let(:property) { double('property', :required? => true) }
					let(:generated_property) { double('generated property') }

					it 'should generate an object with one attribute' do
						AttributeFactory.should_receive(:create).with(property_attributes).and_return(property)
						property.should_receive(:generate).and_return(generated_property)

						described_class.new(attributes).generate.should == {
							'foo' => generated_property
						}
					end
				end

				context 'with many properties' do
					let(:attributes) do
						{
							'type' => 'object',
							'properties' => {
								'foo' => foo_attributes,
								'bar' => bar_attributes,
								'not_required' => not_required_attributes
							},
							'required' => true
						}
					end
					let(:foo_attributes) { double('foo attributes') }
					let(:foo_property) { double('foo property', :required? => true) }
					let(:generated_foo) { double('generated foo') }

					let(:bar_attributes) { double('bar attributes') }
					let(:bar_property) { double('bar property', :required? => true) }
					let(:generated_bar) { double('generated bar') }

					let(:not_required_attributes) { double('not required attributes') }
					let(:not_required_property) { double('not required property', :required? => false) }

					it 'should generate an object with many attributes' do
						AttributeFactory.should_receive(:create).with(foo_attributes).and_return(foo_property)
						foo_property.should_receive(:generate).and_return(generated_foo)

						AttributeFactory.should_receive(:create).with(bar_attributes).and_return(bar_property)
						bar_property.should_receive(:generate).and_return(generated_bar)

						AttributeFactory.should_receive(:create).with(not_required_attributes).and_return(not_required_property)

						described_class.new(attributes).generate.should == {
							'foo' => generated_foo,
							'bar' => generated_bar
						}
					end
				end
			end
		end
	end
end
