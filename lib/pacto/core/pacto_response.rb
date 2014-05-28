module Pacto
  class PactoResponse
    attr_accessor :body, :headers, :status

    def initialize(data)
      @headers = data[:headers]
      @body    = data[:body]
      @status  = data[:status]
    end
  end
end
