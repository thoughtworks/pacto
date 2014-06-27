module Pacto
  describe RequestClause do
    let(:host)           { 'http://localhost' }
    let(:method)         { 'GET' }
    let(:path)           { '/hello_world' }
    let(:headers)        { { 'accept' => 'application/json' } }
    let(:params)         { { 'foo' => 'bar' } }
    let(:body)           { double :body }
    let(:params_as_json) { "{\"foo\":\"bar\"}" }
    let(:absolute_uri)   { "#{host}#{path}" }
    subject(:request) do
      req_hash = {
        host: host,
        'http_method'  => method,
        'path'    => path,
        'headers' => headers,
        'params'  => params
      }
      # The default test is for missing keys, not explicitly nil keys
      req_hash.merge!('schema' => body) if body
      described_class.new(req_hash)
    end

    it 'has a host' do
      expect(request.host).to eq host
    end

    describe '#http_method' do
      it 'delegates to definition' do
        expect(request.http_method).to eq :get
      end

      it 'downcases the method' do
        expect(request.http_method).to eq request.http_method.downcase
      end

      it 'returns a symbol' do
        expect(request.http_method).to be_kind_of Symbol
      end
    end

    describe '#schema' do
      it 'delegates to definition\'s body' do
        expect(request.schema).to eq body
      end

      describe 'when definition does not have a schema' do
        let(:body) { nil }

        it 'returns an empty empty hash' do
          expect(request.schema).to eq({})
        end
      end
    end

    describe '#path' do
      it 'delegates to definition' do
        expect(request.path).to eq path
      end
    end

    describe '#headers' do
      it 'delegates to definition' do
        expect(request.headers).to eq headers
      end
    end

    describe '#params' do
      it 'delegates to definition' do
        expect(request.params).to eq params
      end
    end
  end
end
