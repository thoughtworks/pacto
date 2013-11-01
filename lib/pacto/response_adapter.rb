module Pacto
  class ResponseAdapter
    def initialize(response)
      @response = response
    end

    def status
      @response.code
    end

    def body
      @response.body
    end

    def headers
      # Normalize headers values according to RFC2616
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
      # Also downcase for easier comparison
      normalized_headers = @response.headers.map do |(key, value)|
        [key.downcase, value.join(',')]
      end
      Hash[normalized_headers]
    end
  end
end
