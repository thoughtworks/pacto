describe Pacto::Validation do
  let(:request) { double('request') }
  let(:response) { double('response') }
  let(:contract) { double('contract') }
  let(:validation_results) { double('validation_results') }

  it 'stores the request, response and contract' do
    allow(contract).to receive(:validate)
    validation = Pacto::Validation.new request, response, contract
    expect(validation.request).to eq request
    expect(validation.response).to eq response
  end

  it 'generates and stores the results' do
    expect(contract).to receive(:validate).with(response).and_return(validation_results)
    validation = Pacto::Validation.new request, response, contract
    expect(validation.results).to eq validation_results
  end
end
