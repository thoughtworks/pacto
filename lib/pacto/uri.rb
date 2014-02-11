module Pacto
  class URI
    def initialize(host, path, params = {})
      @host = host
      @path = path
      @params = params
    end

    def uri
      if base_uri.scheme.nil?
        Addressable::URI.parse "http://#{base_uri}"
      else
        base_uri
      end
    end

    def base_uri
      Addressable::URI.parse("#{host}#{path}").tap do |uri|
        uri.query_values = params unless params.empty?
      end
    end

    def to_s
      uri.to_s
    end

    private

    attr_reader :host, :path, :params
  end
end
