module Pacto
  module Server
    class API < Goliath::API
      use ::Rack::ContentLength

      def initialize(opts = {})
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
        options[:strip_port] ||= true

        opts.on('-l', '--live', 'Send requests to live services (instead of stubs)') { |val| options[:live] = true }
        opts.on('--stub', 'Stub responses based on contracts') { |val| options[:stub] = true }
        opts.on('-g', '--generate', 'Generate Contracts from requests') { |val| options[:generate] = true }
        opts.on('-V', '--validate', 'Validate requests/responses against Contracts') { |val| options[:validate] = true }
        opts.on('-m', '--match-strict', 'Enforce strict request matching rules') { |val| options[:strict] = true }
        opts.on('-x', '--contracts_dir DIR', 'Directory that contains the contracts to be registered') { |val| options[:directory] = File.expand_path(val, @original_pwd) }
        opts.on('-H', '--host HOST', 'Host of the real service, for generating or validating live requests') { |val| options[:backend_host] = val }
        opts.on('-r', '--recursive-loading', 'Load contracts from folders named after the host to be stubbed') { |val| options[:recursive_loading] = true }
        opts.on('--strip-port', 'Strip the port from the request URI to build the proxied URI') { |val| options[:strip_port] = true }
        opts.on('--strip-dev', 'Strip .dev from the request domain to build the proxied URI') { |val| options[:strip_dev] = true }
      end

      def response(env)
        log_request(env)
        em_http_request = prepare_em_request(env)
        env.logger.info "forwarding: #{em_http_request.request_signature}"
        resp = EM::Synchrony.sync prepare_em_request(env)
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

      def prepare_em_request(env)
        uri = determine_proxy_uri(env)
        em_request_method = "a#{env['REQUEST_METHOD'].downcase}".to_sym
        em_request_options = {
          :head => filter_request_headers(env),
          :query => env['QUERY_STRING'],
          :body => env['async-body']
        }.delete_if { | k, v | v.nil? }
        EventMachine::HttpRequest.new(uri).send(em_request_method, em_request_options)
      end

      def process_pacto_response(resp, env)
        fail resp.error if resp.error

        code = resp.response_header.http_status
        safe_response_headers = normalize_headers(resp.response_header).reject { |k, v| %w{connection content-encoding content-length transfer-encoding}.include? k.downcase }
        body = proxy_rewrite(resp.response)

        env.logger.debug "response headers: #{safe_response_headers}"
        env.logger.debug "response body: #{body}"
        [code, safe_response_headers, body]
      end

      def determine_proxy_uri(env)
        path = env[Goliath::Request::REQUEST_PATH]
        if env.config[:backend_host]
          uri = Addressable::URI.parse("#{env.config[:backend_host]}#{path}")
        else
          host = env['HTTP_HOST']
          # FIXME: These options are hacky, but cover the way I use in Pacto specs vs Polytrix
          if env.config[:strip_dev]
            host.gsub!(".dev:#{port}", '.com')
          end
          uri = Addressable::URI.parse("https://#{host}#{path}")
          if env.config[:strip_port]
            uri.port = nil
          end
        end
        uri.to_s
      end

      def filter_request_headers(env)
        headers = env['client-headers']
        safe_headers = headers.reject { |k, v| %w{host content-length transfer-encoding}.include? k.downcase }
        env.logger.debug "filtered headers: #{safe_headers}"
        safe_headers
      end

      def port
        env.config[:port]
      end

      def normalize_headers(headers)
        headers.reduce({}) do |res, elem|
          key = elem.first.dup
          value = elem.last
          key.gsub!('_', '-')
          key = key.split('-').map { |w| w.capitalize }.join '-'
          res[key] = value
          res
        end
      end

      def proxy_rewrite(body)
        # FIXME: How I usually deal with rels, but others may not want this behavior.
        body.gsub('.com', ".dev:#{port}").gsub(/https\:([\w\-\.\\\/]+).dev/, 'http:\1.dev')
      end
    end
  end
end
