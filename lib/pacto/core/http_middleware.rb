require 'observer'

module Pacto
  module Core
    class HTTPMiddleware
      include Logger
      include Observable

      def process(request, response)
        contracts = Pacto.contracts_for request
        Pacto.configuration.hook.process contracts, request, response

        changed
        notify_observers request, response
      end
    end
  end
end
