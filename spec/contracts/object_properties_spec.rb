require 'spec_helper'

describe ObjectProperties do
	describe '.expand' do
		let(:properties) { stub('properties') }

		context "quando usando atributos" do
			let(:objeto) { {'properties' => properties} }

			it "deve retornar o próprio objeto" do
				described_class.expand(objeto).should == properties
			end
		end

		describe "quando usando refs" do
			let(:referencer) do
				{
					'type' => 'object',
					'$ref' => '#/definitions/referenced'
				}
			end
			let(:definitions) { {'referenced' => referenced} }
			let(:referenced) { {'properties' => properties} }

			it "deve retornar os atributos do objeto referenciado" do
				described_class.definitions = definitions
				described_class.expand(referencer).should == properties
			end
		end
	end
end
