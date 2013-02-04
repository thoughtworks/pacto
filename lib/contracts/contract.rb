module Contracts
  class Contract
    def initialize(request, response)
    end

    def instantiate(attributes)
      InstantiatedContract.new
    end
  end
end
