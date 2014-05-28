module Pacto
  module Core
    describe SimpleRequestStrategy do
      subject(:strategy) { described_class.new }
      describe '#execute' do
        let(:connection)       { double 'connection' }
        let(:response)         { double 'response' }
        let(:adapted_response) { double 'adapted response' }

        before do
          WebMock.stub_request(:get, 'http://localhost/hello_world?foo=bar').
            to_return(:status => 200, :body => '', :headers => {})
          WebMock.stub_request(:post, 'http://localhost/hello_world?foo=bar').
            to_return(:status => 200, :body => '', :headers => {})
        end

        context 'for any request' do
          xit 'returns the a Faraday response' do
            expect(strategy.execute request).to be_a Faraday::Response
          end
        end

        context 'for a GET request' do
          xit 'makes the request thru the http client' do
            strategy.execute
            expect(WebMock).to have_requested(:get, 'http://localhost/hello_world?foo=bar').
              with(:headers => headers)
          end
        end

        context 'for a POST request' do
          let(:method)  { 'POST' }

          xit 'makes the request thru the http client' do
            strategy.execute
            expect(WebMock).to have_requested(:post, 'http://localhost/hello_world?foo=bar').
              with(:headers => headers)
          end
        end
      end
    end
  end
end
