module Pacto
  describe Response do
    let(:body_definition) do
      {
        :type => 'object',
        :required => true,
        :properties => double('body definition properties')
      }
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

    subject(:response) { Response.new(definition) }

    describe 'the response body' do
      context 'when the definition has an nil body' do
        let(:response) { Response.new(definition.merge('body' => nil)) }

        it 'is nil' do
          expect(response.schema).to eq(Hash.new)
        end
      end
    end

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
