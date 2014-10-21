module Pacto
  module Server
    module Settings
      def options_parser(opts, options) # rubocop:disable MethodLength
        options[:format] ||= :default
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
    end
  end
end
