module Pacto
  class PactoRequest
    attr_reader :headers, :body, :method, :uri

    def initialize(data)
      @headers = data[:header]
      @body    = data[:body]
      @method  = data[:method]
      @uri     = data[:uri]
    end
  end
end
