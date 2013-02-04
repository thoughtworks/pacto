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
		end
	end
end
