# -*- encoding : utf-8 -*-
require 'reel'
require 'pacto'
require_relative 'server/settings'
require_relative 'server/proxy'

module Pacto
  module Server
    class HTTP < Reel::Server::HTTP
      attr_reader :settings, :logger
      include Proxy

      def initialize(host = '127.0.0.1', port = 3000, options = {})
        @settings = Settings::OptionHandler.new(port, @logger).handle(options)
        @logger = Pacto.configuration.logger
        logger.info "Pacto Server starting on #{host}:#{port}"
        super(host, port, spy: options[:spy], &method(:on_connection))
      end

      def on_connection(connection)
        # Support multiple keep-alive requests per connection
        connection.each_request do |reel_request|
          begin
            pacto_request = # exclusive do
              Pacto::PactoRequest.new(
                headers: reel_request.headers, body: reel_request.read,
                method: reel_request.method, uri: Addressable::URI.heuristic_parse(reel_request.uri)
              )
            # end

            pacto_response = proxy_request(pacto_request)
            reel_response = ::Reel::Response.new(pacto_response.status, pacto_response.headers, pacto_response.body)
            reel_request.respond(reel_response)
          rescue WebMock::NetConnectNotAllowedError => e
            reel_request.respond(500, e.message)
          rescue => e
            reel_request.respond(500, e.message)
          end
        end
      end
    end
  end
end
