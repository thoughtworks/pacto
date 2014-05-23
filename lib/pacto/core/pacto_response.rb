module Pacto
  class PactoResponse
    attr_accessor :body, :headers, :status

    def initialize(data)
      @headers = data[:header]
      @body    = data[:body]
      @status  = data[:status]
    end
  end
end
