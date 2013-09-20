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
      contract.validate.should == []
    end
  end

  context 'Stub generation' do
    it 'generates a stub to be used by a consumer' do
      contract = Pacto.build_from_file(contract_path, 'http://dummyprovider.com')
      Pacto.register_contract(contract, 'my_tag')
      Pacto.use('my_tag')
      response.keys.should == ['message']
      response['message'].should be_kind_of(String)
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

      Pacto.register do |r|
        r.register_contract login_contract, :default
        r.register_contract contract, :devices
      end
      Pacto.use(:devices, {:device_id => 42})

      raw_response = HTTParty.get('http://dummyprovider.com/hello', headers: {'Accept' => 'application/json' })
      login_response = JSON.parse(raw_response.body)
      login_response.keys.should == ['message']
      login_response['message'].should be_kind_of(String)

      devices_response = HTTParty.get('http://dummyprovider.com/strict', headers: {'Accept' => 'application/json' })
      devices_response = JSON.parse(devices_response.body)
      devices_response['devices'].should have(2).items
      devices_response['devices'][0].should == '/dev/42'
      # devices_response['devices'][1].should == '/dev/43'
    end
  end
end





