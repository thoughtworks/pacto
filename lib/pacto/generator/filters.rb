module Pacto
  class Generator
    class Filters
      INFORMATIONAL_RESPONSE_HEADERS =
      %w{
        server
        date
        content-length
        connection
      }

      def self.filter_request_headers request, response
        vary_string = response.headers['vary'] || ''
        vary_headers = vary_string.split ','
        request.headers.select do |header|
          vary_headers.map(&:downcase).include? header.downcase
        end
      end

      def self.filter_response_headers request, response
        response.headers.reject do |header|
          INFORMATIONAL_RESPONSE_HEADERS.include? header.downcase
        end
      end
    end
  end
end
