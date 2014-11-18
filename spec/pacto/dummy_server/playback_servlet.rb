# -*- encoding : utf-8 -*-
module Pacto
  module DummyServer
    class PlaybackServlet
      attr_reader :status, :headers, :body

      def initialize(attributes)
        @status = attributes.fetch(:status, 200)
        @headers = attributes.fetch(:headers, [])
        @body = attributes.fetch(:body, nil)
      end

      def do_GET(_request, response) # rubocop:disable MethodName
        response.status = status
        headers.each do |key, value|
          response[key] = value
        end
        response.body = body
      end
    end
  end
end
