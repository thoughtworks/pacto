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

    def to_hash
      {
        method: method,
        uri: uri,
        headers: headers,
        body: body
      }
    end

    def parsed_body
      if body.is_a?(String) && content_type == 'application/json'
        JSON.parse(body)
      else
        body
      end
    rescue
      body
    end

    def content_type
      headers['Content-Type']
    end
  end
end
