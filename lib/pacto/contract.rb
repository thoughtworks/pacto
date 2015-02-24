# -*- encoding : utf-8 -*-
module Pacto
  module Contract
    include Logger

    attr_reader :id
    attr_reader :file
    attr_reader :request
    attr_reader :response
    attr_reader :values
    attr_reader :examples
    attr_reader :name
    attr_writer :adapter
    attr_writer :consumer
    attr_writer :provider

    def adapter
      @adapter ||= Pacto.configuration.adapter
    end

    def consumer
      @consumer ||= Pacto.configuration.default_consumer
    end

    def provider
      @provider ||= Pacto.configuration.default_provider
    end

    def examples?
      examples && !examples.empty?
    end

    def stub_contract!(values = {})
      self.values = values
      adapter.stub_request!(self)
    end

    def simulate_request
      pacto_request, pacto_response = execute
      validate_response pacto_request, pacto_response
    end

    # Should this be deprecated?
    def validate_response(request, response)
      Pacto::Cops.perform_investigation request, response, self
    end

    def matches?(request_signature)
      request_pattern.matches? request_signature
    end

    def request_pattern
      request.pattern
    end

    def response_for(pacto_request)
      provider.response_for self, pacto_request
    end

    def execute(additional_values = {})
      # FIXME: Do we really need to store on the Contract, or just as a param for #stub_contact! and #execute?
      full_values = values.merge(additional_values)
      consumer.reenact(self, full_values)
    end
  end
end
