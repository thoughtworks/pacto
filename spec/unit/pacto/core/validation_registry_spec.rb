describe Pacto::ValidationRegistry do
  subject(:registry) { Pacto::ValidationRegistry.instance }
  let(:request_pattern) { WebMock::RequestPattern.new(:get, 'www.example.com') }
  let(:request_signature) { WebMock::RequestSignature.new(:get, 'www.example.com') }
  let(:different_request_signature) { WebMock::RequestSignature.new(:get, 'www.thoughtworks.com') }
  let(:validation) { Pacto::Validation.new(request_signature, double, nil) }
  let(:validation_for_a_similar_request) { Pacto::Validation.new(request_signature, double, nil) }
  let(:validation_for_a_different_request) { Pacto::Validation.new(different_request_signature, double, nil) }

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
      expect(registry.validated? request_pattern).to be_false
    end

    it 'registers and returns matching validations' do
      registry.register_validation(validation)
      registry.register_validation(validation_for_a_similar_request)
      registry.register_validation(validation_for_a_different_request)
      expect(registry.validated? request_pattern).to eq([validation, validation_for_a_similar_request])
    end
  end
end
