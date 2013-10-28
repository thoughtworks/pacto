module Pacto
  module Server
    class PlaybackServlet
      attr_reader :status, :headers, :body

      def initialize(attributes)
        @status = attributes.fetch(:status, 200)
        @headers = attributes.fetch(:headers, [])
        @body = attributes.fetch(:body, nil)
      end

      def do_GET(request, response) # rubocop:disable MethodName
        response.status = status
        headers.each do |key, value|
          response[key] = value
        end
        response.body = body
      end
    end
  end
end
