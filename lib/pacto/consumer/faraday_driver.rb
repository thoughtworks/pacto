module Pacto
  class Consumer
    class FaradayDriver
      # Sends a Pacto::PactoRequest
      def execute(req)
        conn = Faraday.new(url: req.uri.to_s) do |faraday|
          faraday.response :logger if Pacto.configuration.logger.level == :debug
          faraday.adapter Faraday.default_adapter
        end

        response = conn.send(req.method) do |faraday_request|
          # faraday_request.url = req.uri
          faraday_request.headers = req.headers
          faraday_request.body = (req.body.is_a?(String) ? req.body : req.body.to_json)
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
