module Pacto
  class RequestClause < Hashie::Dash
    include Hashie::Extensions::Coercion
    include Hashie::Extensions::IndifferentAccess # remove this if we cleanup string vs symbol
    property :host # required?
    property :http_method, required: true
    property :schema, default: {}
    property :path
    property :headers
    property :params, default: {}

    def initialize(definition)
      mash = Hashie::Mash.new definition
      mash['http_method'] = normalize(mash['http_method'])
      super mash
    end

    def http_method=(method)
      normalize(method)
    end

    def uri
      @uri ||= Pacto::URI.for(host, path, params)
    end

    private

    def normalize(method)
      method.to_s.downcase.to_sym
    end
  end
end
