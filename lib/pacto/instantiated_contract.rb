module Pacto
  class InstantiatedContract
    attr_reader :response_body

    def initialize(request, response)
      @request = request
      @response = response
      @response_body = response.body
      @stub_provider = ::Pacto::Stubs::StubProvider.instance
    end

    def request_path
      @request.absolute_uri
    end

    def request_uri
      @request.full_uri
    end

    def stub!
      @stub_provider.stub!(@request, @response, @response_body)
    end
  end
end
