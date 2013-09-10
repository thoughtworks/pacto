module Pacto
  module Server
    class PlaybackServlet
      def initialize(json)
        @json = json
      end
      
      def do_GET(request, response)
        response.status = 200
        response['Content-Type'] = 'application/json'
        response.body = @json
      end
    end
  end
end
