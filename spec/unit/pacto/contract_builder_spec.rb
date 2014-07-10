module Pacto
  describe ContractBuilder do
    let(:data) { subject.build_hash }
    describe '#name' do
      it 'sets the contract name' do
        subject.name = 'foo'
        expect(data).to include(name: 'foo')
      end
    end

    context 'generating from interactions' do
      let(:request) { Fabricate(:pacto_request) }
      let(:response) { Fabricate(:pacto_response) }
      let(:data) { subject.generate_response(request, response).build_hash }

      describe '#generate_response' do
        it 'sets the response status' do
          expect(data[:response]).to include({
            status: 200
          })
        end

        it 'sets response headers' do
          expect(data[:response][:headers]).to be_a(Hash)
        end
      end
    end
  end
end
