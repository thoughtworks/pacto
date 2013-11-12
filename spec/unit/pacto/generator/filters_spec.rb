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
        subject(:filtered_request_headers) { described_class.filter_request_headers(request, response_adapter).keys.map(&:downcase) }
        it 'keeps important request headers' do
          expect(filtered_request_headers).to include 'user-agent'
        end

        it 'filters informational request headers' do
          expect(filtered_request_headers).not_to include 'date'
          expect(filtered_request_headers).not_to include 'server'
          expect(filtered_request_headers).not_to include 'content-length'
          expect(filtered_request_headers).not_to include 'connection'
        end
      end

      describe '#filter_response_headers' do
        subject(:filtered_response_headers) { described_class.filter_response_headers(request, response_adapter).keys.map(&:downcase) }
        it 'keeps important response headers' do
          expect(filtered_response_headers).to include 'content-type'
        end

        it 'filters connection control headers' do
          expect(filtered_response_headers).not_to include 'content-length'
          expect(filtered_response_headers).not_to include 'via'
        end

        it 'filters freshness headers' do
        end

        it 'filters x-* headers' do
          expect(filtered_response_headers).not_to include 'x-men'
        end
      end
    end
  end
end
