# -*- encoding : utf-8 -*-
module Pacto
  module DummyServer
    module JRubyWorkaroundHelper
      include Pacto::TestHelper

      def run_pacto
        WebMock.allow_net_connect!
        with_pacto(port: 8000, strip_port: true) do
          yield
        end
      end
    end
  end
end
