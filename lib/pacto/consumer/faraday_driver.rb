# -*- encoding : utf-8 -*-
module Pacto
  class Consumer
    class FaradayDriver
      include Pacto::Logger
      # Sends a Pacto::PactoRequest
      def execute(req)
        conn_options = { url: req.uri.site }
        conn_options[:proxy] = Pacto.configuration.proxy if Pacto.configuration.proxy
        conn = Faraday.new(conn_options) do |faraday|
          faraday.response :logger if Pacto.configuration.logger.level == :debug
          faraday.adapter Faraday.default_adapter
        end

        response = conn.send(req.method) do |faraday_request|
          faraday_request.url(req.uri.path, req.uri.query_values)
          faraday_request.headers = req.headers
          faraday_request.body = req.raw_body
        end

        faraday_to_pacto_response response
      end

      private

      # This belongs in an adapter
      def faraday_to_pacto_response(faraday_response)
        data = {
          status: faraday_response.status,
          headers: faraday_response.headers,
          body: faraday_response.body
        }
        Pacto::PactoResponse.new(data)
      end
    end
  end
end
