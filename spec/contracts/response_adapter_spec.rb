module Contracts
  describe ResponseAdapter do
    let(:response) do
      double({
        :code => 200,
        :headers => {'foo' => ['bar', 'baz'], 'hello' => ['world']},
        :body => double('body')
      })
    end

    before do
      @response_adapter = described_class.new(response)
    end

    it 'should have a status' do
      @response_adapter.status.should == response.code
    end

    it 'should have a body' do
      @response_adapter.body.should == response.body
    end

    it 'should normalize headers values according to RFC2616' do
      @response_adapter.headers.should == {'foo' => 'bar,baz', 'hello' => 'world'}
    end
  end
end
