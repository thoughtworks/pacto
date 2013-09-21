module Pacto
  class Contract
    def initialize(request, response)
      @request = request
      @response = response
    end

    def instantiate
      InstantiatedContract.new(@request, stub_response)
    end

    def validate(response_gotten = provider_response, opt={})
      @response.validate(response_gotten, opt)
    end

    private

    def provider_response
      @request.execute
    end

    def stub_response
      @response.instantiate
    end
  end
end
