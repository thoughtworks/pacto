module Pacto
  describe Response do
    let(:body_definition) do
      {:type => 'object', :required => true, :properties => double('body definition properties')}
    end
    let(:definition) do
      {
        'status' => 200,
        'headers' => {
          'Content-Type' => 'application/json'
        },
        'body' => body_definition
      }
    end
    subject(:response) { described_class.new(definition) }

    describe '#instantiate' do
      let(:generated_body) { double('generated body') }

      it 'instantiates a response with a body that matches the given definition' do
        JSON::Generator.should_receive(:generate).
          with(definition['body']).
          and_return(generated_body)

        instantiated_response = response.instantiate
        expect(instantiated_response.status).to eq definition['status']
        expect(instantiated_response.headers).to eq definition['headers']
        expect(instantiated_response.body).to eq generated_body
      end
    end
  end
end
