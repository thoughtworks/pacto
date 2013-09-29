describe 'Pacto' do
  let(:contract_path) { 'spec/integration/data/simple_contract.json' }
  let(:strict_contract_path) { 'spec/integration/data/strict_contract.json' }

  before :all do
    WebMock.allow_net_connect!
  end

  context 'Contract validation' do
    before :all do
      @server = Pacto::Server::Dummy.new 8000, '/hello', '{"message": "Hello World!"}'
      @server.start
    end

    after :all do
      @server.terminate
    end

    it 'verifies the contract against a producer' do
      contract = Pacto.build_from_file(contract_path, 'http://localhost:8000')
      expect(contract.validate).to be_empty
    end
  end

  context 'Stub generation' do
    it 'generates a stub to be used by a consumer' do
      contract = Pacto.build_from_file(contract_path, 'http://dummyprovider.com')
      Pacto.register_contract(contract, 'my_tag')
      Pacto.use('my_tag')
      expect(response.keys).to eq ['message']
      expect(response['message']).to be_kind_of(String)
    end

    let :response do
      raw_response = HTTParty.get('http://dummyprovider.com/hello', headers: {'Accept' => 'application/json' })
      JSON.parse(raw_response.body)
    end
  end

  context 'Journey' do
    it 'stubs multiple services with a single use' do

      Pacto.configure do |c|
        c.postprocessor = Pacto::ERBProcessor.new
        c.preprocessor = nil
      end

      login_contract = Pacto.build_from_file(contract_path, 'http://dummyprovider.com')
      contract = Pacto.build_from_file(strict_contract_path, 'http://dummyprovider.com')

      Pacto.configure do |c|
        c.register_contract login_contract, :default
        c.register_contract contract, :devices
      end
      Pacto.use(:devices, {:device_id => 42})

      raw_response = HTTParty.get('http://dummyprovider.com/hello', headers: {'Accept' => 'application/json' })
      login_response = JSON.parse(raw_response.body)
      expect(login_response.keys).to eq ['message']
      expect(login_response['message']).to be_kind_of(String)

      devices_response = HTTParty.get('http://dummyprovider.com/strict', headers: {'Accept' => 'application/json' })
      devices_response = JSON.parse(devices_response.body)
      expect(devices_response['devices']).to have(2).items
      expect(devices_response['devices'][0]).to eq '/dev/42'
      # devices_response['devices'][1].should == '/dev/43'
    end
  end
end
