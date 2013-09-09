require 'securerandom'
require 'pacto/erb_processor'

describe 'Echo' do
  
  let(:contract_path) { 'spec/integration/data/echo_contract.json' }
  
  let(:key) { SecureRandom.hex }
  let :response do
    contract = Pacto.build_from_file(contract_path, 'http://dummyprovider.com')
    
    Pacto.register('my_contract', contract)
    Pacto.use('my_contract', {:key => key})
    
    raw_response = HTTParty.get("http://dummyprovider.com/echo", headers: {'Accept' => 'application/json' })
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
      end
      
      response.keys.should == ['message']
      response['message'].should eql('<%=key%>')
    end
  
  end
  
  context 'Post processing' do
    
    it 'should process erb on each request' do
      Pacto.configure do |c|
        c.preprocessor = nil
        c.postprocessor = Pacto::ERBProcessor.new
      end
      
      response.keys.should == ['message']
      response['message'].should eql(key)
    end
  
  end
  
  
end