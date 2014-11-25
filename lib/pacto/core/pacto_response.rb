# -*- encoding : utf-8 -*-
module Pacto
  class PactoResponse
    # FIXME: Need case insensitive header lookup, but case-sensitive storage
    attr_accessor :headers, :body, :status, :parsed_body
    attr_reader :parsed_body

    include BodyParsing

    def initialize(data)
      mash = Hashie::Mash.new data
      @headers = mash.headers.nil? ? {} : mash.headers
      @body = mash.body
      @status  = mash.status.to_i
    end

    def to_hash
      {
        status: status,
        headers: headers,
        body: body
      }
    end

    def to_s
      string = "STATUS: #{status}"
      string << " with body (#{raw_body.bytesize} bytes)" if raw_body
      string
    end
  end
end
