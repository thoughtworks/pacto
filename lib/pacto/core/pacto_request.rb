require 'hashie/mash'

module Pacto
  class PactoRequest
    attr_reader :headers, :body, :method, :uri

    def initialize(data)
      mash = Hashie::Mash.new data
      @headers = mash.headers
      @body    = mash.body
      @method  = mash[:method]
      @uri     = mash.uri
    end
  end
end
