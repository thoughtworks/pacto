# -*- encoding : utf-8 -*-
require 'pacto/server/settings'

module Pacto
  module Server
    class API < Goliath::API
      include Pacto::Server::Settings
      use ::Rack::ContentLength

      def initialize(*args)
        @original_pwd = Dir.pwd
        super
      end

      def on_headers(env, headers)
        env.logger.debug 'receiving headers: ' + headers.inspect
        env['client-headers'] = headers
      end

      def on_body(env, data)
        env.logger.debug 'received data: ' + data
        (env['async-body'] ||= '') << data
      end

      def response(env)
        log_request(env)
        req = prepare_pacto_request(env)
        env.logger.info "sending: #{req}"
        resp = Pacto::Consumer::FaradayDriver.new.execute(req)
        process_pacto_response resp, env
      rescue => e
        backtrace = e.backtrace.join("\n")
        env.logger.warn "responding with error: #{e.message}, backtrace: #{backtrace}"
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
          method: env['REQUEST_METHOD'].downcase.to_sym,
          uri: determine_proxy_uri(env)
        )
      end

      def process_pacto_response(resp, _env)
        code = resp.status
        safe_response_headers = normalize_headers(resp.headers).reject { |k, _v| %w(connection content-encoding content-length transfer-encoding).include? k.downcase }
        body = proxy_rewrite(resp.body)
        env.logger.info "received response: #{resp.inspect}"
        env.logger.debug "response body: #{body}"
        [code, safe_response_headers, body]
      end

      def determine_proxy_uri(env)
        path = env[Goliath::Request::REQUEST_PATH]
        if env.config[:backend_host]
          uri = Addressable::URI.heuristic_parse("#{env.config[:backend_host]}#{path}")
        else
          host = env['HTTP_HOST']
          host.gsub!('.dev', '.com') if env.config[:strip_dev]
          uri = Addressable::URI.heuristic_parse("https://#{host}#{path}")
          uri.port = nil if env.config[:strip_port]
        end
        uri
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
          key = key.split('-').map(&:capitalize).join '-'
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
