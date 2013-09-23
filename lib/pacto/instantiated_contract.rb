module Pacto
  class InstantiatedContract
    attr_reader :response

    def initialize(request, response)
      @request = request
      @response = response
      @stub = Pacto.configuration.provider.stub!(@request, @response) unless request.nil?
    end
  end
end
