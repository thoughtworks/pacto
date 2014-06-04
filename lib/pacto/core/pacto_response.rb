module Pacto
  class PactoResponse
    # FIXME: Need case insensitive header lookup, but case-sensitive storage
    attr_accessor :headers, :body, :status

    def initialize(data)
      mash = Hashie::Mash.new data
      @headers = mash.headers.nil? ? {} : mash.headers
      @body    = mash.body
      @status  = mash.status.to_i
    end
  end
end
