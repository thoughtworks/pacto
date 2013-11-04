module Pacto
  module Stubs
    class BuiltIn

      def initialize
        register_callbacks
      end

      def stub_request! request, response, stub = true
        strict = Pacto.configuration.strict_matchers
        host_pattern = request.host
        path_pattern = request.path
        if strict
          uri_matcher = "#{host_pattern}#{path_pattern}"
        else
          path_pattern = path_pattern.gsub(/\/:\w+/, '/[:\w]+')
          host_pattern = Regexp.quote(request.host)
          uri_matcher = /#{host_pattern}#{path_pattern}/
        end
        request_pattern = WebMock::RequestPattern.new(request.method, uri_matcher)
        request_pattern.with(request_details(request)) if strict
        if stub
          stub = WebMock.stub_request(request.method, uri_matcher)
          stub.request_pattern = request_pattern
          stub.to_return(
            :status => response.status,
            :headers => response.headers,
            :body => format_body(response.body)
          )
        end
        request_pattern
      end

      def reset!
        WebMock.reset!
        WebMock.reset_callbacks
      end

      private

      def register_callbacks
        WebMock.after_request do |request_signature, response|
          contracts = Pacto.contracts_for request_signature
          Pacto.configuration.callback.process contracts, request_signature, response
        end
      end

      def format_body(body)
        if body.is_a?(Hash) || body.is_a?(Array)
          body.to_json
        else
          body
        end
      end

      def request_details request
        details = {}
        unless request.params.empty?
          details[webmock_params_key(request)] = request.params
        end
        unless request.headers.empty?
          details[:headers] = request.headers
        end
        details
      end

      def webmock_params_key request
        request.method == :get ? :query : :body
      end
    end
  end
end
