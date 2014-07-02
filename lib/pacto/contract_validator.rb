module Pacto
  class ContractValidator
    class << self
      def validate(request_signature, pacto_response)
        return unless Pacto.validating?
        contracts = Pacto.contracts_for(request_signature)
        if contracts.empty?
          # This is kinda dumb
          validation = Validation.new request_signature, pacto_response, nil, nil
          Pacto::ValidationRegistry.instance.register_validation validation
        else
          contracts.each do |contract|
            validation = validate_contract request_signature, pacto_response, contract
            Pacto::ValidationRegistry.instance.register_validation validation
          end
        end
      end

      def validate_contract(request, response, contract)
        env = {
          contract: contract,
          actual_request: request,
          actual_response: response,
          validation_results: []
        }
        validation_stack.call env
        results = env[:validation_results].compact

        Validation.new request, response, contract, results
      end

      private

      def validation_stack
        Middleware::Builder.new do
          use Pacto::Validators::RequestBodyValidator
          use Pacto::Validators::ResponseStatusValidator
          use Pacto::Validators::ResponseHeaderValidator
          use Pacto::Validators::ResponseBodyValidator
        end
      end
    end
  end
end
