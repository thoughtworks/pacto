module Pacto
  module Validators
    describe ResponseStatusValidator do
      subject(:validator) { described_class }
      describe '#validate' do
        context 'when status does not match' do
          it 'returns a status error' do
            expect(validator.validate(200, 500)).to eq ['Invalid status: expected 200 but got 500']
          end
        end

        context 'when the status matches' do
          it 'returns nil' do
            expect(validator.validate(200, 200)).to be_nil
          end
        end
      end
    end
  end
end
