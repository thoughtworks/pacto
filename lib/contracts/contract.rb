module Contracts
  class Contract
    def initialize(request, response)
      @request = request
      @response = response
    end

    def instantiate(values = {})
      instantiated_contract = InstantiatedContract.new(@request, @response.instantiate)
      instantiated_contract.replace!(values)
      instantiated_contract
    end
  end
end
