require 'hashie/mash'

module Pacto
  class PactoRequest
    # FIXME: Need case insensitive header lookup, but case-sensitive storage
    attr_accessor :headers, :body, :method, :uri

    def initialize(data)
      mash = Hashie::Mash.new data
      @headers = mash.headers.nil? ? {} : mash.headers
      @body    = mash.body
      @method  = normalize(mash[:method])
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

    def to_s
      string = Pacto::UI.colorize_method(method)
      string << " #{relative_uri}"
      string << " with body (#{body.bytesize} bytes)" if body
      string
    end

    def relative_uri
      uri.to_s.tap do |s|
        s.slice!(uri.normalized_site)
      end
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

    def normalize(method)
      method.to_s.downcase.to_sym
    end
  end
end
