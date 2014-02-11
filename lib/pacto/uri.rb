module Pacto
  class URI
    def initialize(host, path)
      @host = host
      @path = path
    end

    def uri
      if base_uri.scheme.nil?
        Addressable::URI.parse "http://#{base_uri}"
      else
        base_uri
      end
    end

    def base_uri
      Addressable::URI.parse("#{host}#{path}")
    end

    def to_s
      uri.to_s
    end

    private

    attr_reader :host, :path
  end
end
