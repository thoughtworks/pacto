# -*- encoding : utf-8 -*-
require 'pacto/test_helper'

module Pacto
  module DummyServer
    module JRubyWorkaroundHelper
      include Pacto::TestHelper

      def run_pacto
        WebMock.allow_net_connect!
        # There are issues with EventMachine on JRuby, so it can't currently us with_pacto
        if RUBY_PLATFORM == 'java'
          @server = Pacto::DummyServer::Dummy.new 8000, '/hello', '{"message": "Hello World!"}'
          @server.start
          yield
          @server.terminate
        else
          with_pacto(port: 8000, strip_port: true, directory: DEFAULT_CONTRACTS_DIR) do
            yield
          end
        end
      end
    end
  end
end
