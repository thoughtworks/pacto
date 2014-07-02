module Pacto
  module Cops
    describe ResponseStatusCop do
      subject(:cop) { described_class }
      let(:contract) { Fabricate(:contract) }
      let(:request) { Fabricate(:pacto_request) }

      describe '#investigate' do
        context 'when status does not match' do
          let(:response) { Fabricate(:pacto_response, status: 500) }
          it 'returns a status error' do
            expect(cop.investigate(request, response, contract)).to eq ['Invalid status: expected 200 but got 500']
          end
        end

        context 'when the status matches' do
          let(:response) { Fabricate(:pacto_response, status: 200) }
          it 'returns nil' do
            expect(cop.investigate(request, response, contract)).to be_empty
          end
        end
      end
    end
  end
end
