module Pacto
  class URI
    def self.for(host, path, params = {})
      base_uri = Addressable::URI.parse("#{host}#{path}")
      base_uri = Addressable::URI.parse("http://#{base_uri}") if base_uri.scheme.nil?
      base_uri.query_values = params unless params.empty?
      new(base_uri)
    end

    def initialize(base_uri)
      @base_uri = base_uri
    end

    def to_s
      @base_uri.to_s
    end
  end
end
