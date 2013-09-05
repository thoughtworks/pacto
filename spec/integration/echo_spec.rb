require 'securerandom'

describe 'Echo' do
  
  let(:contract_path) { 'spec/integration/data/echo_contract.json' }

  before :all do
    Pacto.unregister_all!
  end

  context 'No processing' do
    
    it 'should not proccess erb tag' do
      
      Pacto.configure do |c|
        c.preprocessor = nil
      end
      
      key = SecureRandom.hex
      
      response.keys.should == ['message']
      response['message'].should eql('<%=key%>')
    end
    
    let :response do
      contract = Pacto.build_from_file(contract_path, 'http://dummyprovider.com')
      
      Pacto.register('my_contract', contract)
      Pacto.use('my_contract')
      
      raw_response = HTTParty.get("http://dummyprovider.com/echo", headers: {'Accept' => 'application/json' })
      JSON.parse(raw_response.body)
    end

  end
  
  
end