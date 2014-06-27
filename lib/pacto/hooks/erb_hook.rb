require_relative '../erb_processor'

module Pacto
  module Hooks
    class ERBHook < Pacto::Hook
      def initialize
        @processor = ERBProcessor.new
      end

      def process(contracts, request_signature, response)
        bound_values = contracts.empty? ? {} : contracts.first.values
        bound_values.merge!(req: { 'HEADERS' => request_signature.headers })
        response.body = @processor.process response.body, bound_values
        response.body
      end
    end
  end
end
