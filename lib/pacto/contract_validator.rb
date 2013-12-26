module Pacto
  class ContractValidator
    class << self
      def validate contract, request, response, opts
        env = {
          :contract => contract,
          :actual_request => request,
          :actual_response => response,
          :validation_results => []
        }
        validation_stack(opts).call env
        env[:validation_results].compact
      end

      private

      def validation_stack opts
        Middleware::Builder.new do
          unless opts[:body_only]
            use Pacto::Validators::ResponseStatusValidator
            use Pacto::Validators::ResponseHeaderValidator
          end
          use Pacto::Validators::ResponseBodyValidator
        end
      end
    end
  end
end
