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
    property :request_builder, default: Pacto::Actors::JSONGenerator

    def initialize(definition)
      mash = Hashie::Mash.new definition
      mash['method'] = normalize(mash['method'])
      super mash
    end

    def method=(method)
      normalize(method)
    end

    def uri
      @uri ||= Pacto::URI.for(host, path, params)
    end

    # FIXME: Send a PR to Hashie so it doesn't coerce values that already match the target class
    def self.coerce(value)
      if value.is_a? self
        value
      else
        RequestClause.new value
      end
    end

    private

    def normalize(method)
      method.to_s.downcase.to_sym
    end
  end
end
