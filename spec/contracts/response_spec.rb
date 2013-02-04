module Contracts
	describe Response do
		describe '#instantiate' do
			let(:attributes) { {} }
			let(:generated_body) { double('generated body') }
			let(:definition) do
				{
					'status' => 200,
					'headers' => {},
					'body' => double('definition body')
				}
			end

			it 'should instantiate a response with a body that matches the given definition' do
				JSON::Generator.should_receive(:generate).
					with(definition['body'], attributes).
					and_return(generated_body)

				response = described_class.new(definition)
				response.instantiate(attributes).should == {
					'status'  => definition['status'],
					'headers' => definition['headers'],
					'body'    => generated_body
				}
			end
		end
	end
end
