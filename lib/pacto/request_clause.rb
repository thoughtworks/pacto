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
      mash = Hashie::Mash.new definition
      mash['method'] = mash['method'].to_s.downcase.to_sym
      super mash
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
  end
end
