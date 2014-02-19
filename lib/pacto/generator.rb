require 'json/schema_generator'

module Pacto
  class Generator
    def initialize(schema_generator = JSON::SchemaGenerator,
      validator = Pacto::MetaSchema.new,
      generator_options = Pacto.configuration.generator_options,
      filters = Pacto::Generator::Filters.new,
      tokenizer = Pacto::Generator::Tokenizer.new)
      @validator = validator
      @schema_generator = schema_generator
      @generator_options = generator_options
      @filters = filters
      @tokenizer = tokenizer
    end

    def save(source, request, response)
      contract = generate_contract source, request, response
      contract = @tokenizer.tokenize contract
      pretty_contract = MultiJson.encode(contract, :pretty => true)
      # This is because of a discrepency w/ jruby vs MRI pretty json
      pretty_contract.gsub!(/^$\n/, '')
      @validator.validate pretty_contract
      pretty_contract
    end

    private

    def generate_contract(source, request, response)
      {
        'request' => generate_request(request, response, source),
        'response' => generate_response(request, response, source)
      }
    end

    def generate_request(request, response, source)
      {
        'headers' => @filters.filter_request_headers(request, response),
        'method' => request.method,
        'params' => request.params,
        'path' => request.path,
        'body' => generate_body(source, request.body)
      }.delete_if { |k, v| v.nil? }
    end

    def generate_response(request, response, source)
      {
        'headers' => @filters.filter_response_headers(request, response),
        'status' => response.status,
        'body' => generate_body(source, response.body)
      }.delete_if { |k, v| v.nil? }
    end

    def generate_body(source, body)
      if body && !body.empty?
        body_schema = JSON::SchemaGenerator.generate source, body, @generator_options
        MultiJson.load(body_schema)
      end
    end
  end
end
