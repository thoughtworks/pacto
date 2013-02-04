module Contracts
  class Contract
    def initialize(request, response)
      @request = request
      @response = response
    end

    def instantiate(attributes = {})
      InstantiatedContract.new(@request, @response.instantiate(attributes))
    end
  end
end
