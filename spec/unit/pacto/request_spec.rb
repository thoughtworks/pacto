module Pacto
  describe Request do
    let(:host)           { 'http://localhost' }
    let(:method)         { 'GET' }
    let(:path)           { '/hello_world' }
    let(:headers)        { {'accept' => 'application/json'} }
    let(:params)         { {'foo' => 'bar'} }
    let(:params_as_json) { "{\"foo\":\"bar\"}" }
    let(:absolute_uri)   { "#{host}#{path}" }
    subject(:request) do
      described_class.new(host,
                          'method'  => method,
                          'path'    => path,
                          'headers' => headers,
                          'params'  => params
      )
    end

    it 'has a host' do
      expect(request.host).to eq host
    end

    describe '#method' do
      it 'delegates to definition' do
        expect(request.method).to eq :get
      end

      it 'downcases the method' do
        expect(request.method).to eq request.method.downcase
      end

      it 'returns a symbol' do
        expect(request.method).to be_kind_of Symbol
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

    describe '#execute' do
      let(:connection)       { double 'connection' }
      let(:response)         { double 'response' }
      let(:adapted_response) { double 'adapted response' }

      before do
        WebMock.stub_request(:get, 'http://localhost/hello_world').
          to_return(:status => 200, :body => '', :headers => {})
        WebMock.stub_request(:post, 'http://localhost/hello_world').
          to_return(:status => 200, :body => '', :headers => {})
        # TODO: Should we just use WebMock?
      end

      context 'for any request' do
        it 'returns the a Faraday response' do
          expect(request.execute).to be_a Faraday::Response
        end
      end

      context 'for a GET request' do
        it 'makes the request thru the http client' do
          request.execute
          expect(WebMock).to have_requested(:get, 'http://localhost/hello_world').
            with(:headers => headers)
        end
      end

      context 'for a POST request' do
        let(:method)  { 'POST' }

        it 'makes the request thru the http client' do
          request.execute
          expect(WebMock).to have_requested(:post, 'http://localhost/hello_world').
            with(:headers => headers)
        end
      end
    end

    describe '#absolute_uri' do
      it 'returns the host followed by the path' do
        expect(request.absolute_uri).to eq absolute_uri
      end
    end

    describe '#full_uri' do
      context 'when the request has a query' do
        it 'returns the host followed by the path and the query' do
          expect(request.full_uri).to eq 'http://localhost/hello_world?foo=bar'
        end
      end

      context 'when the query does not have a query' do
        let(:params) { {} }

        it 'returns the host followed by the path' do
          expect(request.absolute_uri).to eq 'http://localhost/hello_world'
        end
      end
    end
  end
end
