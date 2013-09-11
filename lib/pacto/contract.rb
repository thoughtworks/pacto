module Pacto
  class Contract
    def initialize(request, response)
      @request = request
      @response = response
    end

    def instantiate
      instantiated_contract = InstantiatedContract.new(@request, @response.instantiate)
      instantiated_contract
    end

    def validate(actual_request, actual_response)
      @request.validate actual_request
      if ENV["DEBUG_CONTRACTS"]
        puts "[DEBUG] Response: #{response_gotten.inspect}"
      end
      @response.validate actual_reponse
    end
    
    def replay
      response_gotten = @request.execute
      validate response_gotten
    end
  end
end
