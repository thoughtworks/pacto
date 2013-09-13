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
    
    def validate_response (reponse_gotten, opt={})
      @response.validate(reponse_gotten, opt)
    end

    def validate
      response_gotten = @request.execute
      if ENV["DEBUG_CONTRACTS"]
 require "contract"
        puts "[DEBUG] Response: #{response_gotten.inspect}"
      end
      @response.validate(response_gotten)
    end
  end
end
