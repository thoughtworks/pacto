begin
  require 'pacto'
  require 'goliath/test_helper'
  require 'pacto/server'
rescue LoadError
  raise 'pacto/test_helper requires the goliath and pacto-server gems'
end

module Pacto
  module TestHelper
    include Goliath::TestHelper
    DEFAULT_ARGS = {
      stdout: true,
      log_file: 'pacto.log',
      # :config => 'pacto/config/pacto_server.rb',
      strict: false,
      stub: true,
      live: false,
      generate: false,
      verbose: true,
      validate: true,
      directory: File.join(Dir.pwd, 'spec', 'fixtures', 'contracts'),
      port: 9000
    }

    def with_pacto(args = DEFAULT_ARGS)
      args = DEFAULT_ARGS.merge args
      with_api(Pacto::Server::API, args) do
        EM::Synchrony.defer do
          yield "http://localhost:#{@test_server_port}"
          EM.stop
        end
      end
    end
  end
end
