# -*- encoding : utf-8 -*-
require 'reel'
require 'pacto'
require 'pacto/server/settings'

module Pacto
  module Server
    class HTTP < Reel::Server::HTTP
      def initialize(host = '127.0.0.1', port = 3000, options = {})
        # logger = Pacto.configuration.logger
        logger = Celluloid.logger
        Settings::OptionHandler.new(port, logger).handle(options)
        super(host, port, &method(:on_connection))
      end

      def on_connection(connection)
        # Support multiple keep-alive requests per connection
        connection.each_request do |reel_request|
          begin
            pacto_request = exclusive do
              Pacto::PactoRequest.new(
                headers: reel_request.headers, body: reel_request.read,
                method: reel_request.method, uri: Addressable::URI.heuristic_parse(reel_request.uri)
              )
            end

            pacto_response = Proxy.request(pacto_request)
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

    class Proxy
      class << self
        def request(pacto_request)
          prepare_to_forward(pacto_request)
          pacto_response = forward(pacto_request)
          prepare_to_respond(pacto_response)
          pacto_response
        end

        def prepare_to_forward(pacto_request)
          host = pacto_request.uri.site || pacto_request.headers['Host']
          host.gsub!('.dev', '.com')
          scheme, host = host.split('://')
          host, scheme = scheme, host if host.nil?
          host, _port = host.split(':')
          scheme ||= 'https'
          pacto_request.uri = Addressable::URI.heuristic_parse("#{scheme}://#{host}#{pacto_request.uri}")
          pacto_request.headers.delete_if { |k, _v| %w(host content-length transfer-encoding).include? k.downcase }
        end

        def forward(pacto_request)
          Pacto::Consumer::FaradayDriver.new.execute(pacto_request)
        end

        def prepare_to_respond(pacto_response)
          pacto_response.headers.delete_if { |k, _v| %w(connection content-encoding content-length transfer-encoding).include? k.downcase }
        end
      end
    end
  end
end
