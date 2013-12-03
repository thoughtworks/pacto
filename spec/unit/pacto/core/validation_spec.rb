describe Pacto::Validation do
  let(:request) { double('request') }
  let(:response) { double('response') }
  let(:contract) { double('contract') }
  let(:validation_results) { double('validation_results') }

  before(:each) do
    allow(contract).to receive(:validate)
  end

  it 'stores the request, response and contract' do
    validation = Pacto::Validation.new request, response, contract
    expect(validation.request).to eq request
    expect(validation.response).to eq response
  end

  it 'generates and stores the results' do
    expect(contract).to receive(:validate).with(response).and_return(validation_results)
    validation = Pacto::Validation.new request, response, contract
    expect(validation.results).to eq validation_results
  end

  describe '#successful?' do
    subject(:validation) do
      Pacto::Validation.new request, response, contract
    end

    it 'returns true if there were no validation errors' do
      expect(validation.successful?).to be_true
    end

    it 'returns false if there were validation errors' do
      expect(validation.successful?).to be_true
    end
  end

  describe '#against_contract?' do
    it 'returns nil if there was no contract' do
      validation = Pacto::Validation.new request, response, nil
      expect(validation.against_contract? 'a').to be_nil
    end

    it 'returns the contract with an exact string name match' do
      allow(contract).to receive(:file).and_return('foo')
      validation = Pacto::Validation.new request, response, contract
      expect(validation.against_contract? 'foo').to eq(contract)
      expect(validation.against_contract? 'bar').to be_nil
    end

    it 'returns the contract if there is a regex match' do
      allow(contract).to receive(:file).and_return 'foobar'
      validation = Pacto::Validation.new request, response, contract
      expect(validation.against_contract? /foo/).to eq(contract)
      expect(validation.against_contract? /bar/).to eq(contract)
      expect(validation.against_contract? /baz/).to be_nil
    end
  end
end
