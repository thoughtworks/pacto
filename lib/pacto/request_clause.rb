module Pacto
  class RequestClause < Hashie::Dash
    include Hashie::Extensions::Coercion
    # include Hashie::Extensions::IndifferentAccess # remove this if we cleanup string vs symbol
    property :host # required?
    property :method, required: true
    property :schema, default: {}
    property :path
    property :headers
    property :params, default: {}

    def initialize(definition)
      definition['method'] = definition['method'].to_s.downcase.to_sym
      super
    end

    def uri
      @uri ||= Pacto::URI.for(host, path, params)
    end

    def body
      JSON::Generator.generate(schema)
    end

    def execute
      conn = Faraday.new(:url => uri.to_s) do |faraday|
        faraday.response :logger if Pacto.configuration.logger.level == :debug
        faraday.adapter  Faraday.default_adapter
      end
      conn.send(method) do |req|
        req.headers = headers
      end
    end

    # FIXME: Send a PR to Hashie so it doesn't coerce values that already match the target class
    def self.coerce(value)
      if value.is_a? self
        value
      else
        RequestClause.new value
      end
    end
  end
end
