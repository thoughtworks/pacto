module Contracts
  class InstantiatedContract
    def initialize(request, response)
      @request = request
      @response = response
      @response_body = response.body
    end

    def replace!(values)
      @response_body.deep_merge!(values)
    end

    def stub!
      WebMock.stub_request(@request.method, "#{@request.host}#{@request.path}").
        with({
          :headers => @request.headers,
          webmock_params_key => @request.params
        }).
        to_return({
          :status => @response.status,
          :headers => @response.headers,
          :body => @response_body.to_json
        })
    end

    private
    def webmock_params_key
      @request.method == :get ? :query : :body
    end
  end
end
