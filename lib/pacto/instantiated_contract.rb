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

    def replace!(values)
      if @response_body.respond_to?(:normalize_keys)
        @response_body = @response_body.normalize_keys.deep_merge(values.normalize_keys)
      else
        @response_body = values
      end
    end

    def stub!
      @stub_provider.stub!(@request, @response, @response_body)
    end
  end
end
