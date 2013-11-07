module Pacto
  class Generator
    describe Filters do
      let(:record_host) do
        'http://example.com'
      end
      let(:request) do
        Pacto::Request.new(record_host, {
          'method' => 'GET',
          'path' => '/abcd',
          'headers' => {
            'Content-Length' => [1234],
            'Via' => ['Some Proxy'],
            'User-Agent' => ['rspec']
          },
          'params' => {
            'apikey' => "<%= ENV['MY_API_KEY'] %>"
          }
        })
      end
      let(:response_adapter) do
        Pacto::ResponseAdapter.new(
          OpenStruct.new(
            'status' => 200,
            'headers' => {
              'Date' => [Time.now],
              'Server' => ['Fake Server'],
              'Content-Type' => ['application/json'],
              'Vary' => ['User-Agent']
            },
            'body' => double('dummy body')
          )
        )
      end

      describe '#filter_request_headers' do
        subject(:filtered_request_headers) { described_class.filter_request_headers request, response_adapter }
        it 'keeps important request headers' do
          expect(filtered_request_headers.keys).to include 'User-Agent'
        end

        it 'filters informational request headers' do
          expect(filtered_request_headers).not_to include 'Date'
          expect(filtered_request_headers).not_to include 'Server'
          expect(filtered_request_headers).not_to include 'Content-Length'
          expect(filtered_request_headers).not_to include 'Connection'
        end
      end

      describe '#filter_request_headers' do
        subject(:filtered_response_headers) { described_class.filter_response_headers request, response_adapter }
        it 'keeps important response headers' do
          expect(filtered_response_headers.keys).to include 'Content-Type'.downcase
        end

        it 'filters informational response headers' do
          expect(filtered_response_headers).not_to include 'Content-Length'
          expect(filtered_response_headers).not_to include 'Content-Length'.downcase
          expect(filtered_response_headers).not_to include 'Via'
          expect(filtered_response_headers).not_to include 'Via'.downcase
        end
      end
    end
  end
end
