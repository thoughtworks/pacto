module Pacto
  module Stubs
    class BuiltIn
      attr_accessor :values

      def initialize
        register_callbacks
      end

      def stub! request, response, response_body
        stub = WebMock.stub_request(request.method, "#{request.host}#{request.path}")
        stub = stub.with(request_details(request)) if Pacto.configuration.strict_matchers
        stub.to_return({
            :status => response.status,
            :headers => response.headers,
            :body => format_body(response_body)
          })
      end

      def process(request_signature, response)
        unless processor.nil?
          bound_values = {}
          bound_values.merge!({:req => {'HEADERS' => request_signature.headers}}) if processor.class == ERBProcessor
          bound_values.merge @values unless @values.nil?
          response.body = processor.process response.body, bound_values
        end
        response.body
      end

      private

      def register_callbacks
        WebMock.after_request do |request_signature, response|
          self.process request_signature, response
        end
      end

      def processor
        Pacto.configuration.postprocessor
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
