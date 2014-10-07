describe Pacto::InvestigationRegistry do
  subject(:registry) { described_class.instance }
  let(:request_pattern) { Fabricate(:webmock_request_pattern) }
  let(:request_signature) { Fabricate(:webmock_request_signature) }
  let(:pacto_response) { Fabricate(:pacto_response) }
  let(:different_request_signature) { Fabricate(:webmock_request_signature, uri: 'www.thoughtworks.com') }
  let(:investigation) { Pacto::Investigation.new(request_signature, pacto_response, nil, []) }
  let(:investigation_for_a_similar_request) { Pacto::Investigation.new(request_signature, pacto_response, nil, []) }
  let(:investigation_for_a_different_request) { Pacto::Investigation.new(different_request_signature, pacto_response, nil, []) }

  before(:each) do
    registry.reset!
  end

  describe 'reset!' do
    before(:each) do
      registry.register_investigation(investigation)
    end

    it 'cleans investigations' do
      expect { registry.reset! }.to change { registry.validated? request_pattern }.from([investigation]).to(nil)
    end
  end

  describe 'registering and reporting registered investigations' do
    it 'returns registered investigation' do
      expect(registry.register_investigation investigation).to eq(investigation)
    end

    it 'reports if investigation is not registered' do
      expect(registry.validated? request_pattern).to be_falsey
    end

    it 'registers and returns matching investigations' do
      registry.register_investigation(investigation)
      registry.register_investigation(investigation_for_a_similar_request)
      registry.register_investigation(investigation_for_a_different_request)
      expect(registry.validated? request_pattern).to eq([investigation, investigation_for_a_similar_request])
    end
  end

  describe '.unmatched_investigations' do
    let(:contract) { Fabricate(:contract) }

    it 'returns investigations with no contract' do
      investigation_with_citations = Pacto::Investigation.new(different_request_signature, pacto_response, contract, [])
      registry.register_investigation(investigation)
      registry.register_investigation(investigation_for_a_similar_request)
      registry.register_investigation(investigation_for_a_different_request)
      registry.register_investigation(investigation_with_citations)

      expect(registry.unmatched_investigations).to match_array([investigation, investigation_for_a_similar_request, investigation_for_a_different_request])
    end
  end

  describe '.failed_investigations' do
    let(:contract) { Fabricate(:contract) }
    let(:citations2) { ['a sample citation'] }

    it 'returns investigations with unsuccessful citations' do
      allow(contract).to receive(:name).and_return 'test'
      investigation_with_successful_citations = Pacto::Investigation.new(request_signature, pacto_response, nil, ['error'])
      investigation_with_unsuccessful_citations = Pacto::Investigation.new(request_signature, pacto_response, nil, %w(error2 error3))

      # Twice because of debug statement...
      expect(investigation_with_successful_citations).to receive(:successful?).twice.and_return true
      expect(investigation_with_unsuccessful_citations).to receive(:successful?).twice.and_return false

      registry.register_investigation(investigation)
      registry.register_investigation(investigation_with_successful_citations)
      registry.register_investigation(investigation_with_unsuccessful_citations)

      expect(registry.failed_investigations).to match_array([investigation_with_unsuccessful_citations])
    end
  end
end
