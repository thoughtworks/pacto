module JSON
	module Generator
		describe IntegerAttribute do
			it 'deve ser um BasicAttribute' do
				described_class.new(nil).should be_kind_of(BasicAttribute)
			end

			context 'sem valor padrão' do
				it 'deve retornar o valor padrão' do
					properties = {
						'type' => 'integer'
					}
					described_class.new(properties).generate.should == 0
				end
			end
		end
	end
end
