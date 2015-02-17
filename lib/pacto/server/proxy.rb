module Pacto
  module Server
    module Proxy
      def proxy_request(pacto_request)
        prepare_to_forward(pacto_request)
        pacto_response = forward(pacto_request)
        prepare_to_respond(pacto_response)
        rewrite(pacto_response.body)
        pacto_response
      end

      def prepare_to_forward(pacto_request)
        host = host_for(pacto_request)
        fail 'Could not determine request host' if host.nil?
        host.gsub!('.dev', '.com') if settings[:strip_dev]
        scheme, host = host.split('://')
        host, scheme = scheme, host if host.nil?
        host, _port = host.split(':')
        scheme ||= 'https'
        pacto_request.uri = Addressable::URI.heuristic_parse("#{scheme}://#{host}#{pacto_request.uri}")
        # FIXME: We're stripping accept-encoding and transfer-encoding rather than dealing with the encodings
        pacto_request.headers.delete_if { |k, _v| %w(host content-length accept-encoding transfer-encoding).include? k.downcase }
      end

      def rewrite(body)
        return unless body
        # FIXME: This is pretty hacky and needs to be rethought, but here to support hypermedia APIs
        # This rewrites the response body so that URLs that may link to other services are rewritten
        # to also passs through the Pacto server.
        body.gsub('.com', ".dev:#{settings[:port]}").gsub(/https\:([\w\-\.\\\/]+).dev/, 'http:\1.dev') if settings[:strip_dev]
      end

      def forward(pacto_request)
        Pacto::Consumer::FaradayDriver.new.execute(pacto_request)
      end

      def prepare_to_respond(pacto_response)
        pacto_response.headers.delete_if { |k, _v| %w(connection content-encoding content-length transfer-encoding).include? k.downcase }
      end

      private

      def host_for(pacto_request)
        # FIXME: Need case insensitive fetch for headers
        pacto_request.uri.site || pacto_request.headers.find { |key, _| key.downcase == 'host' }[1]
      end
    end
  end
end
