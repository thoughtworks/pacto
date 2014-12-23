# -*- encoding : utf-8 -*-
module Pacto
  class PactoResponse
    # FIXME: Need case insensitive header lookup, but case-sensitive storage
    attr_accessor :headers, :body, :status, :parsed_body
    attr_reader :parsed_body

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
      string << " with body (#{raw_body.bytesize} bytes)" if body
      string
    end

    def raw_body
      if content_type == 'application/json'
        case body
        when String
          body
        else
          JSON.dump(body)
        end
      else
        body.to_s
      end
    end

    def parsed_body
      if body.is_a?(String) && content_type == 'application/json'
        JSON.parse(body)
      else
        body
      end
    end

    def content_type
      headers['Content-Type']
    end
  end
end
