require 'thor'
require 'pacto/server'

module Pacto
  module Server
    class CLI < Thor
      class << self
        DEFAULTS = {
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
          port: 9000,
          format: :legacy,
          stenographer_log_file: File.expand_path('pacto_stenographer.log', Dir.pwd),
          strip_port: true
        }

        def server_options
          method_option :port, default: 4567, desc: 'The port to run the server on'
          method_option :directory, default: DEFAULTS[:directory], desc: 'The directory containing contracts'
          method_option :strict, default: DEFAULTS[:strict], desc: 'Whether Pacto should use strict matching or not'
          method_option :format, default: DEFAULTS[:format], desc: 'The contract format to use'
          method_option :strip_port, default: DEFAULTS[:strip_port], desc: 'If pacto should remove the port from URLs before forwarding'
        end
      end

      desc 'stub [CONTRACTS...]', 'Launches a stub server for a set of contracts'
      method_option :port, type: :numeric, desc: 'The port to listen on', default: 3000
      method_option :spy, type: :boolean, desc: 'Display traffic received by Pacto'
      server_options
      def stub(*_contracts)
        setup_interrupt
        server_options = @options.dup
        server_options[:stub] = true
        Pacto::Server::HTTP.run('0.0.0.0', options.port, server_options)
      end

      desc 'proxy [CONTRACTS...]', 'Launches an intercepting proxy server for a set of contracts'
      method_option :to, type: :string, desc: 'The target host for forwarded requests'
      method_option :port, type: :numeric, desc: 'The port to listen on', default: 3000
      method_option :spy, type: :boolean, desc: 'Display traffic received by Pacto'
      def proxy(*_contracts)
        setup_interrupt
        server_options = @options.dup
        server_options[:live] = true
        Pacto::Server::HTTP.run('0.0.0.0', options.port, server_options)
      end

      private

      def setup_interrupt
        trap('INT') do
          say 'Exiting...'
          exit
        end
      end
    end
  end
end
