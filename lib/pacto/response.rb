module Pacto
  class Response
    attr_reader :status, :headers, :schema

    def initialize(definition)
      @definition = definition
      @status = @definition['status']
      @headers = @definition['headers']
      @schema = @definition['body']
      @validation_stack = Middleware::Builder.new do
        use Pacto::Validators::ResponseStatusValidator
        use Pacto::Validators::ResponseHeaderValidator
        use Pacto::Validators::ResponseBodyValidator
      end
    end

    def instantiate
      OpenStruct.new(
        'status' => @definition['status'],
        'headers' => @definition['headers'],
        'body' => JSON::Generator.generate(@definition['body'])
      )
    end

    def validate(response, opt = {})
      if opt[:body_only]
        @validation_stack = Middleware::Builder.new do
          use Pacto::Validators::ResponseBodyValidator
        end
      end

      env = {
        :response_definition => @definition,
        :actual_response => response,
        :validation_results => []
      }
      @validation_stack.call env
      env[:validation_results].compact
    end
  end
end
