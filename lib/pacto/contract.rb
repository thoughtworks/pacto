module Pacto
  class Contract < Hashie::Dash
    include Hashie::Extensions::Coercion
    property :file, required: true
    property :request,  required: true
    property :response, required: true
    property :values, default: {}
    # Gotta figure out how to use test doubles w/ coercion
    coerce_key :request,  RequestClause
    coerce_key :response, ResponseClause
    property :name
    property :request_pattern_provider, default: Pacto::RequestPattern
    attr_reader :request_pattern

    def initialize(opts)
      opts[:file] = Addressable::URI.convert_path(opts[:file].to_s).to_s
      opts[:name] ||= opts[:file]
      super
      @request_pattern = request_pattern_provider.for(request)
    end

    def stub_contract!(values = {})
      self.values = values
      Pacto.configuration.provider.stub_request!(request, response)
    end

    def validate_provider(opts = {})
      validate_consumer request, provider_response, opts
    end

    def validate_consumer(request, response, opts = {})
      Pacto::ContractValidator.validate self, request, response, opts
    end

    def matches?(request_signature)
      request_pattern.matches? request_signature
    end

    private

    def provider_response
      request.execute
    end
  end
end
