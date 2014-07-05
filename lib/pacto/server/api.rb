module Pacto
  module Server
    class API < Goliath::API
      use ::Rack::ContentLength

      def initialize(_opts = {})
        @original_pwd = Dir.pwd
      end

      def on_headers(env, headers)
        env.logger.debug 'receiving headers: ' + headers.inspect
        env['client-headers'] = headers
      end

      def on_body(env, data)
        env.logger.debug 'received data: ' + data
        (env['async-body'] ||= '') << data
      end

      def options_parser(opts, options) # rubocop:disable MethodLength
        options[:strict] ||= false
        options[:directory] ||= File.expand_path('contracts', @original_pwd)
        options[:config] ||= File.expand_path('../config.rb', __FILE__)
        options[:stenographer_log_file] ||= File.expand_path('pacto_stenographer.log', @original_pwd)
        options[:strip_port] ||= true

        opts.on('-l', '--live', 'Send requests to live services (instead of stubs)') { |_val| options[:live] = true }
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
      end

      def response(env)
        log_request(env)
        req = prepare_pacto_request(env)
        resp = Pacto::Consumer::FaradayDriver.new.execute(req)
        process_pacto_response resp, env
      rescue => e
        env.logger.warn "responding with error: #{e.message}"
        [500, {}, e.message]
      end

      private

      def log_request(env)
        method = env['REQUEST_METHOD'].upcase
        env.logger.info "received: #{method} #{env['REQUEST_URI']} with headers #{env['client-headers']}"
      end

      def prepare_pacto_request(env)
        PactoRequest.new(
          body: env['async-body'],
          headers: filter_request_headers(env),
          method: :get,
          uri: determine_proxy_uri(env)
        )
      end

      def process_pacto_response(resp, _env)
        code = resp.status
        safe_response_headers = normalize_headers(resp.headers).reject { |k, _v| %w(connection content-encoding content-length transfer-encoding).include? k.downcase }
        body = proxy_rewrite(resp.body)
        [code, safe_response_headers, body]
      end

      def determine_proxy_uri(env)
        path = env[Goliath::Request::REQUEST_PATH]
        if env.config[:backend_host]
          uri = Addressable::URI.parse("#{env.config[:backend_host]}#{path}")
        else
          host = env['HTTP_HOST']
          # FIXME: These options are hacky, but cover the way I use in Pacto specs vs Polytrix
          host.gsub!(".dev:#{port}", '.com') if env.config[:strip_dev]
          uri = Addressable::URI.parse("https://#{host}#{path}")
          uri.port = nil if env.config[:strip_port]
        end
        uri.to_s
      end

      def filter_request_headers(env)
        headers = env['client-headers']
        safe_headers = headers.reject { |k, _v| %w(host content-length transfer-encoding).include? k.downcase }
        env.logger.debug "filtered headers: #{safe_headers}"
        safe_headers
      end

      def port
        env.config[:port]
      end

      def normalize_headers(headers)
        headers.each_with_object({}) do |elem, res|
          key = elem.first.dup
          value = elem.last
          key.gsub!('_', '-')
          key = key.split('-').map { |w| w.capitalize }.join '-'
          res[key] = value
        end
      end

      def proxy_rewrite(body)
        # FIXME: How I usually deal with rels, but others may not want this behavior.
        body.gsub('.com', ".dev:#{port}").gsub(/https\:([\w\-\.\\\/]+).dev/, 'http:\1.dev')
      end
    end
  end
end
