module Pacto
  class RequestPattern < WebMock::RequestPattern
    def self.for(base_request)
      uri_pattern = UriPattern.for(base_request)
      Pacto::RequestPattern.new(base_request.http_method, uri_pattern)
    end

    def to_s
      string = Pacto::UI.colorize_method(@method_pattern.to_s)
      string << " #{@uri_pattern}"
      # WebMock includes this info, but I don't think we should. Pacto should match on URIs only and then validate the rest...
      # string << " with body #{@body_pattern.to_s}" if @body_pattern
      # string << " with headers #{@headers_pattern.to_s}" if @headers_pattern
      # string << " with given block" if @with_block
      string
    end
  end
end
