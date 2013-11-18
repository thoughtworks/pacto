module Pacto
  class Generator
    class Filters
      CONNECTION_CONTROL_HEADERS = %w{
        via
        server
        connection
        transfer-encoding
        content-length
      }

      FRESHNESS_HEADERS =
      %w{
        date
        last-modified
        etag
      }

      HEADERS_TO_FILTER = CONNECTION_CONTROL_HEADERS + FRESHNESS_HEADERS

      def self.filter_request_headers request, response
        vary_string = response.headers['vary'] || ''
        vary_headers = vary_string.split ','
        request.headers.select do |header|
          vary_headers.map(&:downcase).include? header.downcase
        end
      end

      def self.filter_response_headers request, response
        response.headers.reject do |header|
          header = header.downcase
          (HEADERS_TO_FILTER.include? header) || (header.start_with?('x-'))
        end
      end
    end
  end
end
