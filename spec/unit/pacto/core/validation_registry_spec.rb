describe Pacto::ValidationRegistry do
  subject(:registry) { Pacto::ValidationRegistry.instance }
  let(:request_pattern) { Fabricate(:webmock_request_pattern) }
  let(:request_signature) { Fabricate(:webmock_request_signature) }
  let(:different_request_signature) { Fabricate(:webmock_request_signature, :uri => 'www.thoughtworks.com') }
  let(:validation) { Pacto::Validation.new(request_signature, double, nil, []) }
  let(:validation_for_a_similar_request) { Pacto::Validation.new(request_signature, double, nil, []) }
  let(:validation_for_a_different_request) { Pacto::Validation.new(different_request_signature, double, nil, []) }

  before(:each) do
    registry.reset!
  end

  describe 'reset!' do
    before(:each) do
      registry.register_validation(validation)
    end

    it 'cleans validations' do
      expect { registry.reset! }.to change { registry.validated? request_pattern }.from([validation]).to(nil)
    end
  end

  describe 'registering and reporting registered validations' do
    it 'returns registered validation' do
      expect(registry.register_validation validation).to eq(validation)
    end

    it 'reports if validation is not registered' do
      expect(registry.validated? request_pattern).to be_falsey
    end

    it 'registers and returns matching validations' do
      registry.register_validation(validation)
      registry.register_validation(validation_for_a_similar_request)
      registry.register_validation(validation_for_a_different_request)
      expect(registry.validated? request_pattern).to eq([validation, validation_for_a_similar_request])
    end
  end

  describe '.unmatched_validations' do
    let(:contract) { Fabricate(:contract) }

    it 'returns validations with no contract' do
      validation_with_results = Pacto::Validation.new(different_request_signature, double, contract, [])
      registry.register_validation(validation)
      registry.register_validation(validation_for_a_similar_request)
      registry.register_validation(validation_for_a_different_request)
      registry.register_validation(validation_with_results)

      expect(registry.unmatched_validations).to match_array([validation, validation_for_a_similar_request, validation_for_a_different_request])
    end
  end

  describe '.failed_validations' do
    let(:contract) { Fabricate(:contract) }
    let(:results2) { double('results2', :empty? => false, :join => 'wtf') }

    it 'returns validations with unsuccessful results' do
      allow(contract).to receive(:name).and_return 'test'
      validation_with_successful_results = Pacto::Validation.new(request_signature, double, nil, ['error'])
      validation_with_unsuccessful_results = Pacto::Validation.new(request_signature, double, nil, %w(error2 error3))

      expect(validation_with_successful_results).to receive(:successful?).and_return true
      expect(validation_with_unsuccessful_results).to receive(:successful?).and_return false

      registry.register_validation(validation)
      registry.register_validation(validation_with_successful_results)
      registry.register_validation(validation_with_unsuccessful_results)

      expect(registry.failed_validations).to match_array([validation_with_unsuccessful_results])
    end
  end
end
