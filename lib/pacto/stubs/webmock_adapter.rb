module Pacto
  module Adapters
    module WebMock
      class PactoRequest < Pacto::PactoRequest
        extend Forwardable
        def_delegators :@webmock_request_signature, :headers, :body, :method, :uri, :to_s

        def initialize(webmock_request_signature)
          @webmock_request_signature = webmock_request_signature
        end

        def params
          @webmock_request_signature.uri.query_values
        end

        def path
          @webmock_request_signature.uri.path
        end
      end
      class PactoResponse < Pacto::PactoResponse
        extend Forwardable
        def_delegators :@webmock_response, :body, :body=, :headers=, :status=, :to_s

        def initialize(webmock_response)
          @webmock_response = webmock_response
        end

        def headers
          @webmock_response.headers || {}
        end

        def status
          status, _ = @webmock_response.status
          status
        end
      end
    end
  end
  module Stubs
    class WebMockAdapter
      include Resettable

      def initialize(middleware)
        @middleware = middleware

        WebMock.after_request do |webmock_request_signature, webmock_response|
          process_hooks webmock_request_signature, webmock_response
        end
      end

      def stub_request!(contract)
        request_clause = contract.request
        uri_pattern = UriPattern.for(request_clause)
        stub = WebMock.stub_request(request_clause.method, uri_pattern)

        stub.request_pattern.with(strict_details(request_clause)) if Pacto.configuration.strict_matchers
        response = Pacto::Consumer.actor.build_response contract

        stub.to_return(
          :status => response.status,
          :headers => response.headers,
          :body => format_body(response.body)
        )
      end

      def self.reset!
        WebMock.reset!
        WebMock.reset_callbacks
      end

      def process_hooks(webmock_request_signature, webmock_response)
        pacto_request = Pacto::Adapters::WebMock::PactoRequest.new webmock_request_signature
        pacto_response = Pacto::Adapters::WebMock::PactoResponse.new webmock_response
        @middleware.process pacto_request, pacto_response
      end

      private

      def format_body(body)
        if body.is_a?(Hash) || body.is_a?(Array)
          body.to_json
        else
          body
        end
      end

      def strict_details(request)
        {}.tap do |details|
          unless request.params.empty?
            details[webmock_params_key(request)] = request.params
          end
          unless request.headers.empty?
            details[:headers] = request.headers
          end
        end
      end

      def webmock_params_key(request)
        request.method == :get ? :query : :body
      end
    end
  end
end
