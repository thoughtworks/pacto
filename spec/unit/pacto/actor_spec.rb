RSpec.shared_examples 'an actor' do
  # let(:contract) { Fabricate(:contract) }
  let(:data) do
    {}
  end

  describe '#build_request' do
    let(:request) { subject.build_request contract, data }
    it 'creates a PactoRequest' do
      expect(request).to be_an_instance_of Pacto::PactoRequest
    end
  end

  describe '#build_response' do
    # Shouldn't build response be building a response for a request?
    # let(:request) { Fabricate :pacto_request }
    let(:response) { subject.build_response contract, data }
    it 'creates a PactoResponse' do
      expect(response).to be_an_instance_of Pacto::PactoResponse
    end
  end
end
