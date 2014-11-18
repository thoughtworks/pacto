# -*- encoding : utf-8 -*-
module Pacto
  module Cops
    extend Pacto::Resettable

    class << self
      def reset!
        @active_cops = nil
      end

      def register_cop(cop)
        fail TypeError "#{cop} does not respond to investigate" unless cop.respond_to? :investigate
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
          investigation = perform_investigation request_signature, pacto_response, contract
        else
          investigation = Investigation.new request_signature, pacto_response
        end

        Pacto::InvestigationRegistry.instance.register_investigation investigation
      end

      def perform_investigation(request, response, contract)
        citations = []
        active_cops.map do | cop |
          citations.concat cop.investigate(request, response, contract)
        end
        Investigation.new(request, response, contract, citations.compact)
      end
    end
  end
end
