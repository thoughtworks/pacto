require 'observer'

module Pacto
  module Core
    class HTTPMiddleware
      include Logger
      include Observable

      def process(request, response)
        contracts = Pacto.contracts_for request
        Pacto.configuration.hook.process contracts, request, response

        validate(request, response) if Pacto.validating?
        changed
        notify_observers request, response
      end

      # These will be exacted to other classes soon

      def validate(request_signature, pacto_response)
        return unless Pacto.validating?
        contract = Pacto.contracts_for(request_signature).first
        validation = Validation.new request_signature, pacto_response, contract
        Pacto::ValidationRegistry.instance.register_validation validation
      end
    end
  end
end
