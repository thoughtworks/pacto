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

    def self.from_request_clause(req_clause)
      data = req_clause.to_hash
      data['uri'] = req_clause.uri
      data['body'] = '' # Should be strategy
      new(data)
    end
  end
end
