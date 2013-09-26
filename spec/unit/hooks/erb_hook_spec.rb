describe Pacto::Hooks::ERBHook do
  describe '.process' do
    let(:req) {
      OpenStruct.new({:headers => {'User-Agent' => 'abcd'}})
    }
    let(:converted_req) {
      {'HEADERS' => {'User-Agent' => 'abcd'}}
    }
    let(:res) {
      OpenStruct.new({:body => 'before'})
    }

    before do
    end

    context 'no matching contracts' do
      it 'should bind the request' do
        contracts = Set.new
        mock_erb({ :req => converted_req })
        described_class.new.process contracts, req, res
        res.body.should == 'after'
      end
    end

    context 'one matching contract' do
      it 'should bind the request and the contract\'s values' do
        contract = OpenStruct.new({:values => {:max => 'test'}})
        contracts = Set.new([contract])
        mock_erb({ :req => converted_req, :max => 'test'})
        described_class.new.process contracts, req, res
        res.body.should == 'after'
      end
    end

    context 'multiple matching contracts' do
      it 'should bind the request and the first contract\'s values' do
        contract1 = OpenStruct.new({:values => {:max => 'test'}})
        contract2 = OpenStruct.new({:values => {:mob => 'team'}})
        res = OpenStruct.new({:body => 'before'})
        mock_erb({ :req => converted_req, :max => 'test'})
        contracts = Set.new([contract1, contract2])
        described_class.new.process contracts, req, res
        res.body.should == 'after'
      end
    end
  end

  def mock_erb(hash)
    Pacto::ERBProcessor.any_instance.should_receive(:process).with('before', hash).and_return('after')
  end
end
