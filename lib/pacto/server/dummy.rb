require 'webrick'
require 'forwardable'

module Pacto
  module Server
    class Servlet < WEBrick::HTTPServlet::AbstractServlet
      extend Forwardable

      def initialize server, json
        super(server)

        @doer = PlaybackServlet.new(
          status: 200,
          headers: {'Content-Type' => 'application/json', 'Vary' => 'Accept'},
          body: json
        )
      end

      def_delegator :@doer, :do_GET # rubocop:disable SymbolName
    end

    class Dummy
      def initialize port, path, response
        params = {
          :Port => port,
          :AccessLog => [],
          :Logger => WEBrick::Log.new('/dev/null', 7)
        }
        @server = WEBrick::HTTPServer.new params
        @server.mount path, Servlet, response
      end

      def start
        @pid = Thread.new do
          trap 'INT' do
            @server.shutdown
          end
          @server.start
        end
      end

      def terminate
        @server.shutdown
        @pid.kill
      end
    end
  end
end
