module Pacto
  class URI
    def self.for(host, path, params = {})
      base_uri = Addressable::URI.heuristic_parse("#{host}#{path}")
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
