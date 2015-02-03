# -*- encoding : utf-8 -*-
module Pacto
  module Server
    module Settings
      def options_parser(opts, options) # rubocop:disable MethodLength
        options[:format] ||= :legacy
        options[:strict] ||= false
        options[:directory] ||= File.expand_path('contracts', @original_pwd)
        options[:config] ||= File.expand_path('../config.rb', __FILE__)
        options[:stenographer_log_file] ||= File.expand_path('pacto_stenographer.log', @original_pwd)
        options[:strip_port] ||= true

        opts.on('-l', '--live', 'Send requests to live services (instead of stubs)') { |_val| options[:live] = true }
        opts.on('-f', '--format FORMAT', 'Contract format') { |val| options[:format] = val }
        opts.on('--stub', 'Stub responses based on contracts') { |_val| options[:stub] = true }
        opts.on('-g', '--generate', 'Generate Contracts from requests') { |_val| options[:generate] = true }
        opts.on('-V', '--validate', 'Validate requests/responses against Contracts') { |_val| options[:validate] = true }
        opts.on('-m', '--match-strict', 'Enforce strict request matching rules') { |_val| options[:strict] = true }
        opts.on('-x', '--contracts_dir DIR', 'Directory that contains the contracts to be registered') { |val| options[:directory] = File.expand_path(val, @original_pwd) }
        opts.on('-H', '--host HOST', 'Host of the real service, for generating or validating live requests') { |val| options[:backend_host] = val }
        opts.on('-r', '--recursive-loading', 'Load contracts from folders named after the host to be stubbed') { |_val| options[:recursive_loading] = true }
        opts.on('--strip-port', 'Strip the port from the request URI to build the proxied URI') { |_val| options[:strip_port] = true }
        opts.on('--strip-dev', 'Strip .dev from the request domain to build the proxied URI') { |_val| options[:strip_dev] = true }
        opts.on('--stenographer-log-file', 'Location for the stenographer log file') { |val| options[:stenographer_log_file] = val }
        opts.on('--log-level [LEVEL]', [:debug, :info, :warn, :error, :fatal], 'Pacto log level ( debug, info, warn, error or fatal)') { |val| options[:pacto_log_level] = val }
      end

      class OptionHandler
        attr_reader :port, :logger, :config, :options

        def initialize(port, logger, config = {})
          @port, @logger, @config = port, logger, config
        end

        def token_map
          if File.readable? '.tokens.json'
            MultiJson.load(File.read '.tokens.json')
          else
            {}
          end
        end

        def prepare_contracts(contracts)
          contracts.stub_providers if options[:stub]
        end

        def handle(options)
          @options = options
          config[:backend_host] = options[:backend_host]
          config[:strip_port] = options[:strip_port]
          config[:strip_dev] = options[:strip_dev]
          config[:port] = port
          contracts_path = options[:directory] || File.expand_path('contracts', Dir.pwd)
          Pacto.configure do |pacto_config|
            pacto_config.logger = options[:pacto_logger] || logger
            pacto_config.loggerl.log_level = config[:pacto_log_level] if config[:pacto_log_level]
            pacto_config.contracts_path = contracts_path
            pacto_config.strict_matchers = options[:strict]
            pacto_config.generator_options = {
              schema_version: :draft3,
              token_map: token_map
            }
            pacto_config.stenographer_log_file = options[:stenographer_log_file]
          end

          if options[:generate]
            Pacto.generate!
            logger.info 'Pacto generation mode enabled'
          end

          if options[:recursive_loading]
            Dir["#{contracts_path}/*"].each do |host_dir|
              host = File.basename host_dir
              prepare_contracts Pacto.load_contracts(host_dir, "https://#{host}", options[:format])
            end
          else
            host_pattern = options[:backend_host] || '{scheme}://{server}'
            if File.exist? contracts_path
              prepare_contracts Pacto.load_contracts(contracts_path, host_pattern, options[:format])
            end
          end

          Pacto.validate! if options[:validate]

          if options[:live]
            #  WebMock.reset!
            WebMock.allow_net_connect!
          end

          config
        end
      end
    end
  end
end
