module Pacto
  class ValidatorStack
    def self.validate(request_signature, pacto_response)
      return unless Pacto.validating?

      contract = Pacto.contracts_for(request_signature).first
      if contract
        validation = contract.validate_response request_signature, pacto_response
      else
        validation = Validation.new request_signature, pacto_response
      end

      Pacto::ValidationRegistry.instance.register_validation validation
    end

    def initialize(validators = nil)
      @validators = validators
    end

    def validators
      @validators ||= Pacto.configuration.default_cops
    end

    def validate_contract(request, response, contract)
      results = []
      validators.map do | validator |
        results.concat validator.validate(request, response, contract)
      end
      Validation.new(request, response, contract, results.compact)
    end
  end
end
