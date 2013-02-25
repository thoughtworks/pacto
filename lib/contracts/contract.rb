module Contracts
  class Contract
    def initialize(request, response)
      @request = request
      @response = response
    end

    def instantiate(values = nil)
      instantiated_contract = InstantiatedContract.new(@request, @response.instantiate)
      instantiated_contract.replace!(values)
      instantiated_contract
    end

    def validate
      @response.validate(@request.execute)
    end
  end
end
