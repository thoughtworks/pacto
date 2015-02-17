# -*- encoding : utf-8 -*-
begin
  require 'pacto'
  require 'pacto/server'
rescue LoadError
  raise 'pacto/test_helper requires the pacto-server gem'
end

module Pacto
  module TestHelper
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
      directory: File.join(Dir.pwd, 'contracts'),
      port: 9000,
      format: :legacy,
      stenographer_log_file: File.expand_path('pacto_stenographer.log', Dir.pwd),
      strip_port: true
    }

    def with_pacto(args = {})
      start_index = ::Pacto::InvestigationRegistry.instance.investigations.size
      ::Pacto::InvestigationRegistry.instance.investigations.clear
      args = DEFAULT_ARGS.merge(args)
      args[:spy] = args[:verbose]
      server = Pacto::Server::HTTP.supervise('0.0.0.0', args[:port], args)
      yield "http://localhost:#{args[:port]}"
      ::Pacto::InvestigationRegistry.instance.investigations[start_index, -1]
    ensure
      server.terminate unless server.nil?
    end
  end
end
