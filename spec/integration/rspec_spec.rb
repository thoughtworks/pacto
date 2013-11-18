require 'pacto/rspec'

describe 'pacto/rspec' do
  let(:contract_path) { 'spec/integration/data/simple_contract.json' }
  let(:strict_contract_path) { 'spec/integration/data/strict_contract.json' }

  before :all do
    WebMock.allow_net_connect!
    @server = Pacto::Server::Dummy.new 8000, '/hello', '{"message": "Hello World!"}'
    @server.start
  end

  after :all do
    @server.terminate
  end

  def expect_to_raise(message_pattern = nil, &blk)
    expect { blk.call }.to raise_error(RSpec::Expectations::ExpectationNotMetError, message_pattern)
  end

  def json_response url
    response = HTTParty.get(url, headers: {'Accept' => 'application/json' })
    MultiJson.load(response.body)
  end

  context 'successful validations' do
    before(:each) do
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

      HTTParty.get('http://dummyprovider.com/hello', headers: {'Accept' => 'application/json' })
    end

    it 'performs successful assertions' do
      # High level assertions
      expect(Pacto).to_not have_unmatched_requests
      expect(Pacto).to_not have_failed_validations

      # Increasingly strict assertions
      expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/hello')
      expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/hello').with(:headers => {'Accept' => 'application/json'})
      expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/hello').against_contract(/simple_contract.json/)
    end

    it 'supports negative assertions' do
      expect(Pacto).to_not have_validated(:get, 'http://dummyprovider.com/strict')
      HTTParty.get('http://dummyprovider.com/strict', headers: {'Accept' => 'application/json' })
      expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/strict')
    end

    it 'raises useful error messages' do
      # High level error messages
      expect_to_raise(/Expected Pacto to have not matched all requests to a Contract, but all requests were matched/) { expect(Pacto).to have_unmatched_requests }
      expect_to_raise(/Expected Pacto to have found validation problems, but none were found/) { expect(Pacto).to have_failed_validations }

      unmatched_url = 'http://localhost:8000/404'
      HTTParty.get unmatched_url
      expect_to_raise(/the following requests were not matched.*#{Regexp.quote unmatched_url}/m) { expect(Pacto).to_not have_unmatched_requests }

      # Expected failures
      expect_to_raise(/no matching request was received/) { expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/hello').with(:headers => {'Accept' => 'text/plain'}) }
      # No support for with accepting a block
      # expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/hello').with { |req| req.body == "abc" }
      expect_to_raise(/but it was validated against/) { expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/hello').against_contract(/strict_contract.json/) }
      expect_to_raise(/but it was validated against/) { expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/hello').against_contract('simple_contract.json') }
      expect_to_raise(/but no matching request was received/) { expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/strict') }
    end

    it 'displays Contract validation problems' do
      Pacto.use(:devices, {:device_id => 1.5})
      HTTParty.get('http://dummyprovider.com/strict', headers: {'Accept' => 'application/json' })
      expect_to_raise(/validation errors were found:/) { expect(Pacto).to have_validated(:get, 'http://dummyprovider.com/strict') }

      expect_to_raise(/but the following issues were found:/) { expect(Pacto).to_not have_failed_validations }
    end
  end
end
