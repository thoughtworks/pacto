# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Legacy
      module Generator
        class Filters
          CONNECTION_CONTROL_HEADERS = %w(
            Via
            Server
            Connection
            Transfer-Encoding
            Content-Length
          )

          FRESHNESS_HEADERS =
          %w(
            Date
            Last-Modified
            Etag
            ETag
          )

          IMAGE_HEADERS =
          %w(
            Location
          )

          HEADERS_TO_FILTER = CONNECTION_CONTROL_HEADERS + FRESHNESS_HEADERS + IMAGE_HEADERS

          def filter_request_headers(request, response)
            # FIXME: Do we need to handle all these cases in real situations, or just because of stubbing?
            vary_headers = response.headers['vary'] || response.headers['Vary'] || []
            vary_headers = [vary_headers] if vary_headers.is_a? String
            vary_headers = vary_headers.map do |h|
              h.split(',').map(&:strip)
            end.flatten

            request.headers.select do |header|
              vary_headers.map(&:downcase).include? header.downcase
            end
          end

          def filter_response_headers(_request, response)
            Pacto::Extensions.normalize_header_keys(response.headers).reject do |header|
              (HEADERS_TO_FILTER.include? header) || (header.start_with?('X-'))
            end
          end
        end
      end
    end
  end
end
