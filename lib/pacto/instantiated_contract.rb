module Pacto
  class InstantiatedContract
    attr_reader :response_body, :request, :response,  :stub_provider

    def initialize(request, response, stub_provider=::Pacto::Stubs::WebMockProvider.new)
      @request = request
      @response = response
      @response_body = response.body
      @stub_provider = stub_provider
    end

    def request_path
      request.absolute_uri
    end

    def request_uri
      request.full_uri
    end

    def replace!(values)
      if response_body.respond_to?(:normalize_keys)
        @response_body = response_body.normalize_keys.deep_merge(values.normalize_keys)
      else
        @response_body = values
      end
    end

    def stub!
      stub_provider.stub!(request, response, response_body)
    end
  end
end
