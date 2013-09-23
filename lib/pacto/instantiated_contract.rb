module Pacto
  class InstantiatedContract
    attr_reader :response

    def initialize(request, response)
      @request = request
      @response = response
      @stub_provider = Pacto.configuration.provider
    end

    def request_path
      @request.absolute_uri
    end

    def request_uri
      @request.full_uri
    end

    def stub!
      @stub_provider.stub!(@request, @response)
    end
  end
end
