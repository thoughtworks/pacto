# -*- encoding : utf-8 -*-
module Pacto
  class RequestClause < Pacto::Dash
    include Logger
    property :host # required?
    property :http_method, required: true
    property :schema, default: {}
    property :path, default: '/'
    property :headers
    property :params, default: {}
    attr_accessor :request_pattern_provider

    def initialize(definition)
      mash = Hashie::Mash.new definition
      mash['http_method'] = normalize(mash['http_method'])
      @request_pattern_provider = Pacto::RequestPattern
      super mash
    end

    def http_method=(method)
      normalize(method)
    end

    def pattern
      @pattern ||= request_pattern_provider.for(self)
    end

    def uri(values = {})
      values ||= {}
      uri_template = pattern.uri_template
      missing_keys = (uri_template.keys - values.keys).map(&:to_sym)
      values[:scheme] = 'http' if missing_keys.delete(:scheme)
      values[:server] = 'localhost' if missing_keys.delete(:server)
      logger.warn "Missing keys for building a complete URL: #{missing_keys.inspect}" unless missing_keys.empty?
      Addressable::URI.heuristic_parse(uri_template.expand(values)).tap do |uri|
        uri.query_values = params unless params.nil? || params.empty?
      end
    end

    private

    def normalize(method)
      method.to_s.downcase.to_sym
    end
  end
end
