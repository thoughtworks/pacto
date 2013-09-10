describe 'Pacto' do
  let(:contract_path) { 'spec/integration/data/simple_contract.json' }

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
      Pacto.register('my_contract', contract)
      Pacto.use('my_contract')
      response.keys.should == ['message']
      response['message'].should be_kind_of(String)
    end

    let :response do
      raw_response = HTTParty.get('http://dummyprovider.com/hello', headers: {'Accept' => 'application/json' })
      JSON.parse(raw_response.body)
    end
  end
end
