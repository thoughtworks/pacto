module JSON
	module Generator
		describe BasicAttribute do
			context 'com valor padrão' do
				it 'deve retornar o valor padrão' do
					default = stub('default')
					properties = {
						'default' => default
					}
					described_class.new(properties).generate.should == default
				end
			end
		end
	end
end
