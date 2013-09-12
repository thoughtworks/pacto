module Pacto
  describe ResponseAdapter do
    let(:response) do
      double(
        :code => 200,
        :headers => {'foo' => ['bar', 'baz'], 'hello' => ['world']},
        :body => double('body')
      )
    end

    subject(:response_adapter) { described_class.new response }

    it 'should have a status' do
      expect(response_adapter.status).to eq response.code
    end

    it 'should have a body' do
      expect(response_adapter.body).to eq response.body
    end

    it 'should normalize headers values according to RFC2616' do
      expect(response_adapter.headers).to eq({'foo' => 'bar,baz', 'hello' => 'world'})
    end
  end
end
