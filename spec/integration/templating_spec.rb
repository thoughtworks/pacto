require 'securerandom'
require 'pacto/erb_processor'

describe 'Templating' do
  
  let(:contract_path) { 'spec/integration/data/templating_contract.json' }
  
  let(:key) { SecureRandom.hex }
  let(:auth_token) { SecureRandom.hex }
  let :response do
    contract = Pacto.build_from_file(contract_path, 'http://dummyprovider.com')
    Pacto.register('my_contract', contract)
    Pacto.use('my_contract', {:key => key, :auth_token => auth_token})
    
    raw_response = HTTParty.get("http://dummyprovider.com/echo", headers: {
      'Accept' => 'application/json',
      "Custom-Auth-Token" => "#{auth_token}",
      "X-Message" => "#{key}"
      }
    )
    JSON.parse(raw_response.body)
  end

  before :each do
    Pacto.unregister_all!
  end

  context 'No processing' do
    
    it 'should not proccess erb tag' do
      Pacto.configure do |c|
        c.preprocessor = nil
        c.postprocessor = nil
        c.strict_matchers = false
      end
      
      response.keys.should == ['message']
      response['message'].should eql("<%= req['HEADERS']['X-Message'].reverse %>")
    end
  
  end
  
  context 'Post processing' do
    
    it 'should process erb on each request' do
      Pacto.configure do |c|
        c.preprocessor = nil
        c.postprocessor = Pacto::ERBProcessor.new
      end
      
      response.keys.should == ['message']
      response['message'].should eql(key.reverse)
    end
  
  end
  
  
end