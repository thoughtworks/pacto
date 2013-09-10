require 'webrick'
require 'forwardable'

module Pacto
  module Server
    class Servlet < WEBrick::HTTPServlet::AbstractServlet
      extend Forwardable

      def initialize server, json
        super(server)
        @doer = PlaybackServlet.new json
      end

      def_delegator :@doer, :do_GET
    end

    class Dummy
      def initialize port, path, response
        @server = WEBrick::HTTPServer.new :Port => port,
          :AccessLog => [],
          :Logger => WEBrick::Log::new("/dev/null", 7)
        @server.mount path, Servlet, response
      end

      def start
        @pid = Thread.new do
          trap 'INT' do @server.shutdown end
          @server.start
        end
      end

      def terminate
        @pid.kill
      end
    end
  end
end
