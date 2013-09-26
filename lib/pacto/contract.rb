module Pacto
  class Contract

    def initialize(request, response, file = nil)
      @request = request
      @response = response
      @file = file
    end

    def stub!
      @stub = Pacto.configuration.provider.stub!(@request, stub_response) unless @request.nil?
    end

    def validate(response_gotten = provider_response, opt = {})
      @response.validate(response_gotten, opt)
    end

    def matches? request_signature
      @stub.matches? request_signature unless @stub.nil?
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
