describe Pacto::Hooks::ERBHook do
  describe '#process' do
    let(:req) do
      OpenStruct.new(:headers => {'User-Agent' => 'abcd'})
    end
    let(:converted_req) do
      {'HEADERS' => {'User-Agent' => 'abcd'}}
    end
    let(:res) do
      Pacto::PactoResponse.new(
        :status => 200,
        :body => 'before'
      )
    end

    before do
    end

    context 'no matching contracts' do
      it 'binds the request' do
        contracts = Set.new
        mock_erb(:req => converted_req)
        described_class.new.process contracts, req, res
        expect(res.body).to eq('after')
      end
    end

    context 'one matching contract' do
      it 'binds the request and the contract\'s values' do
        contract = OpenStruct.new(:values => {:max => 'test'})
        contracts = Set.new([contract])
        mock_erb(:req => converted_req, :max => 'test')
        described_class.new.process contracts, req, res
        expect(res.body).to eq('after')
      end
    end

    context 'multiple matching contracts' do
      it 'binds the request and the first contract\'s values' do
        contract1 = OpenStruct.new(:values => {:max => 'test'})
        contract2 = OpenStruct.new(:values => {:mob => 'team'})
        res = Pacto::PactoResponse.new(
          :status => 200,
          :body => 'before'
        )
        mock_erb(:req => converted_req, :max => 'test')
        contracts = Set.new([contract1, contract2])
        described_class.new.process contracts, req, res
        expect(res.body).to eq('after')
      end
    end
  end

  def mock_erb(hash)
    expect_any_instance_of(Pacto::ERBProcessor).to receive(:process).with('before', hash).and_return('after')
  end
end
