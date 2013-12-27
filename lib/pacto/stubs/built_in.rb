require 'pacto/stubs/webmock_helper'

module Pacto
  module Stubs
    class BuiltIn
      def initialize
        register_callbacks
        @logger = Logger.instance
      end

      def stub_request!(request, response, stubbing = true)
        request_pattern = build_request_pattern(request, response, stubbing)
        request_pattern.with(request_details(request)) if Pacto.configuration.strict_matchers
        request_pattern
      end

      def reset!
        WebMock.reset!
        WebMock.reset_callbacks
      end

      def process_callbacks(request_signature, response)
        WebMockHelper.generate(request_signature, response) if Pacto.generating?

        contracts = Pacto.contracts_for request_signature
        Pacto.configuration.callback.process contracts, request_signature, response

        WebMockHelper.validate(request_signature, response) if Pacto.validating?
      end

      private

      def build_uri_pattern(request)
        if Pacto.configuration.strict_matchers
          build_strict_uri_pattern(request)
        else
          build_relaxed_uri_pattern(request)
        end
      end

      def build_strict_uri_pattern(request)
        host_pattern = request.host
        path_pattern = request.path
        "#{host_pattern}#{path_pattern}"
      end

      def build_relaxed_uri_pattern(request)
        path_pattern = request.path
        path_pattern = path_pattern.gsub(/\/:\w+/, '/[^\/\?#]+')
        host_pattern = Regexp.quote(request.host)
        /#{host_pattern}#{path_pattern}/
      end

      def build_stubbed_request_pattern(request, response, uri_pattern)
        stub = WebMock.stub_request(request.method, uri_pattern)
        stub.to_return(
          :status => response.status,
          :headers => response.headers,
          :body => format_body(response.body)
        )
        stub.request_pattern
      end

      def build_request_pattern(request, response, stubbing)
        uri_pattern = build_uri_pattern(request)
        if stubbing
          return build_stubbed_request_pattern(request, response, uri_pattern)
        else
          return WebMock::RequestPattern.new(request.method, uri_pattern)
        end
      end

      def register_callbacks
        WebMock.after_request do |request_signature, response|
          process_callbacks request_signature, response
        end
      end

      def format_body(body)
        if body.is_a?(Hash) || body.is_a?(Array)
          body.to_json
        else
          body
        end
      end

      def request_details(request)
        details = {}
        unless request.params.empty?
          details[webmock_params_key(request)] = request.params
        end
        unless request.headers.empty?
          details[:headers] = request.headers
        end
        details
      end

      def webmock_params_key(request)
        request.method == :get ? :query : :body
      end
    end
  end
end
