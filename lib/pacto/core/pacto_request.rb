require 'hashie/mash'

module Pacto
  class PactoRequest
    # FIXME: Need case insensitive header lookup, but case-sensitive storage
    attr_accessor :headers, :body, :method, :uri

    def initialize(data)
      mash = Hashie::Mash.new data
      @headers = mash.headers.nil? ? {} : mash.headers
      @body    = mash.body
      @method  = mash[:method]
      @uri     = mash.uri
    end
  end
end
