module Pacto
  module Cops
    extend Pacto::Resettable

    class << self
      def reset!
        @active_cops = nil
      end

      def register_cop(cop)
        raise TypeError "#{cop} does not respond to investigate" unless cop.respond_to? :investigate
        registered_cops << cop
      end

      def registered_cops
        @registered_cops ||= Set.new
      end

      def active_cops
        @active_cops ||= registered_cops.dup
      end

      def investigate(request_signature, pacto_response)
        return unless Pacto.validating?

        contract = Pacto.contracts_for(request_signature).first
        if contract
          validation = perform_investigation request_signature, pacto_response, contract
        else
          validation = Validation.new request_signature, pacto_response
        end

        Pacto::ValidationRegistry.instance.register_validation validation
      end

      def perform_investigation(request, response, contract)
        results = []
        active_cops.map do | cop |
          results.concat cop.investigate(request, response, contract)
        end
        Validation.new(request, response, contract, results.compact)
      end
    end
  end
end
