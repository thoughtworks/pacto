module Pacto
  class Contract
    attr_reader :values, :request, :response, :file, :request_pattern

    def initialize(request, response, file, request_pattern_provider = RequestPattern)
      @request = request
      @response = response
      @file = file.to_s
      @request_pattern = request_pattern_provider.for(request)
      @values = {}
    end

    def stub_contract!(values = {})
      @values = values
      Pacto.configuration.provider.stub_request!(request, response)
    end

    def validate_provider(opts = {})
      request = @request
      response = provider_response
      validate_consumer request, response, opts
    end

    def validate_consumer(request, response, opts = {})
      Pacto::ContractValidator.validate self, request, response, opts
    end

    def matches?(request_signature)
      request_pattern.matches? request_signature
    end

    private

    def provider_response
      @request.execute
    end
  end
end
