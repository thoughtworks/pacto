module JSON
	module Generator
		describe ObjectAttribute do
			describe '#generate' do
				context 'without properties' do
					let(:attributes) { {'type' => 'object'} }

					it 'should generate an empty object' do
						described_class.new(attributes).generate.should == {}
					end
				end

				context 'with empty properties' do
					let(:attributes) { {'type' => 'object', 'properties' => {}} }

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
							}
						}
					end
					let(:property_attributes) { double('property attributes') }
					let(:property) { double('property') }
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
								'bar' => bar_attributes
							}
						}
					end
					let(:foo_attributes) { double('foo attributes') }
					let(:foo_property) { double('foo property') }
					let(:generated_foo) { double('generated foo') }

					let(:bar_attributes) { double('bar attributes') }
					let(:bar_property) { double('bar property') }
					let(:generated_bar) { double('generated bar') }

					it 'should generate an object with many attributes' do
						AttributeFactory.should_receive(:create).with(foo_attributes).and_return(foo_property)
						foo_property.should_receive(:generate).and_return(generated_foo)

						AttributeFactory.should_receive(:create).with(bar_attributes).and_return(bar_property)
						bar_property.should_receive(:generate).and_return(generated_bar)

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
