module Pacto
  class Generator
    describe Filters do
      let(:record_host) do
        'http://example.com'
      end
      let(:request) do
        RequestClause.new(
          host: record_host,
          http_method: 'GET',
          path: '/abcd',
          headers: {
            'Server' => ['example.com'],
            'Connection' => ['Close'],
            'Content-Length' => [1234],
            'Via' => ['Some Proxy'],
            'User-Agent' => ['rspec']
          },
          params: {
            'apikey' => "<%= ENV['MY_API_KEY'] %>"
          }
        )
      end
      let(:varies) { ['User-Agent'] }
      let(:response) do
        Faraday::Response.new(
          :status => 200,
          :response_headers => {
            'Date' => Time.now.rfc2822,
            'Last-Modified' => Time.now.rfc2822,
            'ETag' => 'abc123',
            'Server' => ['Fake Server'],
            'Content-Type' => ['application/json'],
            'Vary' => varies
          },
          :body => double('dummy body')
        )
      end

      describe '#filter_request_headers' do
        subject(:filtered_request_headers) { described_class.new.filter_request_headers(request, response).keys.map(&:downcase) }
        it 'keeps important request headers' do
          expect(filtered_request_headers).to include 'user-agent'
        end

        it 'filters informational request headers' do
          expect(filtered_request_headers).not_to include 'via'
          expect(filtered_request_headers).not_to include 'date'
          expect(filtered_request_headers).not_to include 'server'
          expect(filtered_request_headers).not_to include 'content-length'
          expect(filtered_request_headers).not_to include 'connection'
        end

        context 'multiple Vary elements' do
          context 'as a single string' do
            let(:varies) do
              ['User-Agent,Via']
            end
            it 'keeps each header' do
              expect(filtered_request_headers).to include 'user-agent'
              expect(filtered_request_headers).to include 'via'
            end
          end
          context 'as multiple items' do
            let(:varies) do
              %w(User-Agent Via)
            end
            it 'keeps each header' do
              expect(filtered_request_headers).to include 'user-agent'
              expect(filtered_request_headers).to include 'via'
            end
          end
        end
      end

      describe '#filter_response_headers' do
        subject(:filtered_response_headers) { described_class.new.filter_response_headers(request, response).keys.map(&:downcase) }
        it 'keeps important response headers' do
          expect(filtered_response_headers).to include 'content-type'
        end

        it 'filters connection control headers' do
          expect(filtered_response_headers).not_to include 'content-length'
          expect(filtered_response_headers).not_to include 'via'
        end

        it 'filters freshness headers' do
          expect(filtered_response_headers).not_to include 'date'
          expect(filtered_response_headers).not_to include 'last-modified'
          expect(filtered_response_headers).not_to include 'eTag'
        end

        it 'filters x-* headers' do
          expect(filtered_response_headers).not_to include 'x-men'
        end
      end
    end
  end
end
