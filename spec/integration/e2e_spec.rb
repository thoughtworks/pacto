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

  context 'Stubbing a collection of contracts' do
    it 'generates a server that stubs the contract for consumers' do
      contracts = Pacto.build_contracts(contract_path, 'http://dummyprovider.com')
      contracts.stub_all

      response = get_json('http://dummyprovider.com/hello')
      expect(response['message']).to eq 'bar'
    end
  end

  context 'Journey' do
    it 'stubs multiple services with a single use' do
      Pacto.configure do |c|
        c.strict_matchers = false
        c.register_hook Pacto::Hooks::ERBHook.new
      end

      contracts = Pacto.build_contracts 'spec/integration/data/', 'http://dummyprovider.com'
      contracts.stub_all(:device_id => 42)

      login_response = get_json('http://dummyprovider.com/hello')
      expect(login_response.keys).to eq ['message']
      expect(login_response['message']).to be_kind_of(String)

      devices_response = get_json('http://dummyprovider.com/strict')
      expect(devices_response['devices']).to have(2).items
      expect(devices_response['devices'][0]).to eq('/dev/42')
      expect(devices_response['devices'][1]).to eq('/dev/43')
    end
  end

  def get_json(url)
    response = Faraday.get(url) do |req|
      req.headers = {'Accept' => 'application/json' }
    end
    MultiJson.load(response.body)
  end
end
