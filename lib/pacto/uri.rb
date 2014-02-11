module Pacto
  class URI
    def initialize(host, path)
      @host = host
      @path = path
    end

    def to_s
      "#{host}#{path}"
    end

    private
    attr_reader :host, :path
  end
end
