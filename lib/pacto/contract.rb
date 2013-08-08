module Pacto
  class Contract
    def initialize(request, response)
      @request = request
      @response = response
    end

    def instantiate(values = nil)
      instantiated_contract = InstantiatedContract.new(@request, @response.instantiate)
      instantiated_contract.replace!(values) unless values.nil?
      instantiated_contract
    end

    def validate
      response_gotten = @request.execute
      if ENV["DEBUG_CONTRACTS"]
        puts "[DEBUG] Response: #{response_gotten.inspect}"
      end
      @response.validate(response_gotten)
    end
  end
end
