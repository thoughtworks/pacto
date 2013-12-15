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
      if @schema && !@schema.empty?
        OpenStruct.new(
          'status' => @definition['status'],
          'headers' => @definition['headers'],
          'body' => JSON::Generator.generate(@schema)
        )
      else
        OpenStruct.new(
          'status' => @definition['status'],
          'headers' => @definition['headers']
        )
      end
    end
  end
end
