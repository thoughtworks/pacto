module Pacto
  module Observers
    class Stenographer
      def initialize(output)
        @output = output
      end

      def log_validation(validation)
        contract = validation.contract
        request = validation.request
        response = validation.response
        name = name_for(contract, request)
        values = values_for(contract, request)

        @output.puts "detected #{name}, #{response.status}, #{values}"
        @output.puts "  validation errors: #{validation.results}" unless validation.successful?
      end

      protected

      def name_for(contract, request)
        return "Unknown (#{request.uri})" if contract.nil?
        contract.name.inspect
      end

      def values_for(_contract, request)
        # FIXME: Extract vars w/ URI::Template
        request.uri.query_values
      end
    end
  end
end
