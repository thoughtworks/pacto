module Pacto
  module Validators
    describe ResponseStatusValidator do
      subject(:validator) { described_class }
      let(:contract) { Fabricate(:contract) }
      let(:request) { Fabricate(:pacto_request) }

      describe '#validate' do
        context 'when status does not match' do
          let(:response) { Fabricate(:pacto_response, status: 500) }
          it 'returns a status error' do
            expect(validator.validate(request, response, contract)).to eq ['Invalid status: expected 200 but got 500']
          end
        end

        context 'when the status matches' do
          let(:response) { Fabricate(:pacto_response, status: 200) }
          it 'returns nil' do
            expect(validator.validate(request, response, contract)).to be_empty
          end
        end
      end
    end
  end
end
