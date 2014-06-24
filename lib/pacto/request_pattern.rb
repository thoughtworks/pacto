module Pacto
  class RequestPattern
    def self.for(base_request)
      uri_pattern = UriPattern.for(base_request)
      WebMock::RequestPattern.new(base_request.http_method, uri_pattern)
    end
  end
end
