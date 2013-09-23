module Pacto
  class InstantiatedContract
    attr_reader :response

    def initialize(request, response)
      @request = request
      @response = response
      @stub_provider = Pacto.configuration.provider
    end

    def stub!
      @stub_provider.stub!(@request, @response)
    end
  end
end
