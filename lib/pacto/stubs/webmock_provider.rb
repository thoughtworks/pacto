module Pacto
  module Stubs
    class WebMockProvider
      def stub! request, response, response_body
        WebMock.stub_request(request.method, "#{request.host}#{request.path}").
          with(request_details(request)).
          to_return({
            :status => response.status,
            :headers => response.headers,
            :body => format_body(response_body)
          })
      end

      private
      def format_body(body)
        if body.is_a?(Hash) or body.is_a?(Array)
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
