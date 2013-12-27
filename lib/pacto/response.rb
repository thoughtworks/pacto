module Pacto
  class Response
    attr_reader :status, :headers, :schema

    def initialize(definition)
      @definition = definition
      @status = @definition['status']
      @headers = @definition['headers']
      @schema = @definition['body']
    end

    def instantiate
      params = default_params
      params.delete(:body) unless @schema && !@schema.empty?
      Faraday::Response.new(params)
    end

    private

    def default_params
      {
        :status => @definition['status'],
        :response_headers => @definition['headers'],
        :body => JSON::Generator.generate(@schema)
      }
    end
  end
end
