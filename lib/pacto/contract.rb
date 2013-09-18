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
    
    def validate (request = nil, response_gotten = nil, opt={})
      
      request, response_gotten = play_from_contract if (request.nil? && response_gotten.nil?) 
        
      raise ArgumentError, "Pass no args or both request and response" if (response_gotten.nil?)
      if ENV["DEBUG_CONTRACTS"]
        puts "[DEBUG] Response: #{response_gotten.inspect}"
      end
      @response.validate(response_gotten, opt)
    end
    
    private
    def play_from_contract
      [@request, @request.execute]
    end
    
  end
end
