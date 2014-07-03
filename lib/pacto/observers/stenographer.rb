module Pacto
  module Observers
    class Stenographer
      def initialize(output)
        @output = output
      end

      def log_investigation(investigation)
        contract = investigation.contract
        request = investigation.request
        response = investigation.response
        name = name_for(contract, request)
        values = values_for(contract, request)

        msg = "request #{name.inspect}, values: #{values.inspect}, response: {status: #{response.status}} # #{number_of_citations(investigation)} contract violations"
        @output.puts msg
        @output.flush
      end

      protected

      def name_for(contract, request)
        return "Unknown (#{request.uri})" if contract.nil?
        contract.name
      end

      def number_of_citations(investigation)
        return 0 if investigation.nil?
        return 0 if investigation.citations.nil?
        investigation.citations.size.to_s
      end

      def values_for(_contract, request)
        # FIXME: Extract vars w/ URI::Template
        request.uri.query_values
      end
    end
  end
end
