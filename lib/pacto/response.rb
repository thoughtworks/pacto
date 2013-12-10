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
      OpenStruct.new(
        'status' => @definition['status'],
        'headers' => @definition['headers'],
        'body' => JSON::Generator.generate(@definition['body'])
      )
    end

    def validate(response, opt = {})
      unless opt[:body_only]
        status, _description = response.status
        errors = Pacto::Validators::ResponseStatusValidator.validate @definition['status'], status
        return errors unless errors.nil?

        errors = Pacto::Validators::ResponseHeaderValidator.validate @definition['headers'], response.headers
        return errors unless errors.nil?
      end

      Pacto::Validators::ResponseBodyValidator.validate @definition['body'], response
    end
  end
end
