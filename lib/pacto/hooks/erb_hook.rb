module Pacto
  module Hooks
    class ERBHook
      def initialize
        @processor = ERBProcessor.new
      end

      def process(contracts, request_signature, response)
        bound_values = contracts.empty? ? {} : contracts.first.values
        bound_values.merge!({:req => { 'HEADERS' => request_signature.headers}})
        response.body = @processor.process response.body, bound_values
        response.body
      end
      
      def call(contracts, request_signature, response)
        process contracts, request_signature, response
      end
    end
  end
end
