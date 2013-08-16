describe "Pacto" do
  before :all do
    @server = DummyServer.new
    @server.start
  end

  after :all do
    @server.terminate
  end

  let(:contract_path) { 'spec/integration/data/simple_contract.json' }
  let(:end_point_address) { 'http://localhost:8000' }

  it "validates a contract against a server" do
    WebMock.allow_net_connect!
    contract = Pacto.build_from_file(contract_path, end_point_address)
    contract.validate.should == []
  end

  pending "generates a mocked response based on a contract specification" do
    contract = Pacto.build_from_file(contract_path, end_point_address)
    Pacto.register('my_contract', contract)
    Pacto.use('my_contract')

  end
end
