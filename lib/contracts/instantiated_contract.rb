module Contracts
  class InstantiatedContract
    attr_reader :response_body

    def initialize(request, response)
      @request = request
      @response = response
      @response_body = response.body
    end

    def replace!(values)
      if @response_body.nil?
        @response_body = values
      else
        @response_body.deep_merge!(values)
      end
    end

    def stub!
      WebMock.stub_request(@request.method, "#{@request.host}#{@request.path}").
        with(request_details).
        to_return({
          :status => @response.status,
          :headers => @response.headers,
          :body => @response_body.to_json
        })
    end

    private
    def request_details
      details = { webmock_params_key => @request.params }
      unless @request.headers.empty?
        details[:headers] = @request.headers
      end
      details
    end

    def webmock_params_key
      @request.method == :get ? :query : :body
    end
  end
end
