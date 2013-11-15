require 'pacto/rspec'

describe 'pacto/rspec' do
  let(:contract_path) { 'spec/integration/data/simple_contract.json' }
  let(:strict_contract_path) { 'spec/integration/data/strict_contract.json' }

  before :all do
    WebMock.allow_net_connect!
  end

  before :all do
    @server = Pacto::Server::Dummy.new 8000, '/hello', '{"message": "Hello World!"}'
    @server.start
  end

  after :all do
    @server.terminate
  end


  def json_response url
    response = HTTParty.get(url, headers: {'Accept' => 'application/json' })
    MultiJson.load(response.body)
  end

  context 'multiple services' do
    it 'provides validations' do
      Pacto.configure do |c|
        c.strict_matchers = false
        c.postprocessor = Pacto::ERBProcessor.new
        c.preprocessor = nil
        c.register_callback Pacto::Hooks::ERBHook.new
      end

      # Preprocessor must be off before building!
      Pacto.load_all 'spec/integration/data/', 'http://dummyprovider.com', :devices
      Pacto.use(:devices, {:device_id => 42})
      Pacto.validate!

      raw_response = json_response 'http://dummyprovider.com/hello'
      expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/hello').against_contract('abc')
      expect(Pacto).to_not have_validated(:get, 'http://dummyprovider.com/strict')

      devices_response = json_response 'http://dummyprovider.com/strict'
      expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/strict')
      # devices_response['devices'][1].should == '/dev/43'
    end
  end
end
