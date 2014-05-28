module Pacto
  module Consumer
    describe FaradayDriver do
      subject(:strategy) { described_class.new }
      let(:get_request)  { Fabricate(:request_clause, method: :get,  host: 'http://localhost/', path: 'hello_world', params: {'foo' => 'bar'}).to_pacto_request }
      let(:post_request) { Fabricate(:request_clause, method: :post, host: 'http://localhost/', path: 'hello_world', params: {'foo' => 'bar'}).to_pacto_request }

      describe '#execute' do

        before do
          WebMock.stub_request(:get, 'http://localhost/hello_world?foo=bar').
            to_return(:status => 200, :body => '', :headers => {})
          WebMock.stub_request(:post, 'http://localhost/hello_world?foo=bar').
            to_return(:status => 200, :body => '', :headers => {})
        end

        context 'for any request' do
          it 'returns the a Pacto::PactoResponse' do
            expect(strategy.execute get_request).to be_a Pacto::PactoResponse
          end
        end

        context 'for a GET request' do
          it 'makes the request thru the http client' do
            strategy.execute get_request
            expect(WebMock).to have_requested(:get, 'http://localhost/hello_world?foo=bar')
          end
        end

        context 'for a POST request' do
          let(:method)  { 'POST' }

          it 'makes the request thru the http client' do
            strategy.execute post_request
            expect(WebMock).to have_requested(:post, 'http://localhost/hello_world?foo=bar')
          end
        end
      end
    end
  end
end
