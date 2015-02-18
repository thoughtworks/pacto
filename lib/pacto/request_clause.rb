# -*- encoding : utf-8 -*-
module Pacto
  module RequestClause
    include Logger
    attr_reader :host
    attr_reader :http_method
    attr_reader :schema
    attr_reader :path
    attr_reader :headers
    attr_reader :params

    attr_writer :request_pattern_provider

    def request_pattern_provider
      @request_pattern_provider ||= Pacto::RequestPattern
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
      missing_keys = uri_template.keys.map(&:to_sym) - values.keys.map(&:to_sym)
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
