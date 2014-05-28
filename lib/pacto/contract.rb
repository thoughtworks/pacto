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
    property :request_strategy, default: Pacto::Core::SimpleRequestStrategy.new

    def initialize(opts)
      opts[:file] = Addressable::URI.convert_path(opts[:file].to_s).to_s
      opts[:name] ||= opts[:file]
      super
    end

    def stub_contract!(values = {})
      self.values = values
      Pacto.configuration.provider.stub_request!(request, response)
    end

    def validate_provider(opts = {})
      pacto_request, pacto_response = execute
      validate_consumer pacto_request, pacto_response, opts
    end

    # Should this be deprecated?
    def validate_consumer(request, response, opts = {})
      Pacto::ContractValidator.validate_contract request, response, self, opts
    end

    def matches?(request_signature)
      request_pattern.matches? request_signature
    end

    def request_pattern
      @request_pattern ||= request_pattern_provider.for(request)
    end

    def execute
      pacto_request = Pacto::PactoRequest.from_request_clause request
      pacto_response = request_strategy.execute pacto_request
      [pacto_request, pacto_response]
    end
  end
end
