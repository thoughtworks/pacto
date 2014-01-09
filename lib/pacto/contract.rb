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

    def validate(actual_response = provider_response, opts = {})
      # Missing actual request
      Pacto::ContractValidator.validate self, nil, actual_response, opts
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
