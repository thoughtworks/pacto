require 'json/schema_generator'

module Pacto
  class Generator
    def initialize(schema_version = 'draft3',
      schema_generator = JSON::SchemaGenerator,
      validator = Pacto::MetaSchema.new,
      generator_options = Pacto.configuration.generator_options)
      @schema_version = schema_version
      @validator = validator
      @schema_generator = schema_generator
      @generator_options = generator_options
    end

    def generate(request_file, host)
      contract = Pacto.build_from_file request_file, host
      raw_contract = Pacto.build_from_file request_file, host, nil
      request = raw_contract.request
      response = contract.request.execute
      save(request_file, request, response)
    end

    def save(source, request, response)
      contract = generate_contract source, request, response
      pretty_contract = MultiJson.encode(contract, :pretty => true)
      # This is because of a discrepency w/ jruby vs MRI pretty json
      pretty_contract.gsub! /^$\n/, ''
      @validator.validate pretty_contract
      pretty_contract
    end

    private

    def generate_contract source, request, response
      {
        :request => generate_request(request, response),
        :response => generate_response(request, response, source)
      }
    end

    def generate_request request, response
      {
        :headers => Pacto::Generator::Filters.filter_request_headers(request, response),
        :method => request.method,
        :params => request.params,
        :path => request.path
      }
    end

    def generate_response request, response, source
      {
        :headers => Pacto::Generator::Filters.filter_response_headers(request, response),
        :status => response.status,
        :body => generate_body(source, response.body)
      }
    end

    def generate_body source, body
      body_schema = JSON::SchemaGenerator.generate source, body, @generator_options
      MultiJson.load(body_schema)
    end
  end
end
