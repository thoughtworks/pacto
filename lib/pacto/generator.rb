require 'json/schema_generator'

module Pacto
  class Generator
    def initialize(schema_version = 'draft3',
      schema_generator = JSON::SchemaGenerator,
      validator = Pacto::MetaSchema.new)
      @schema_version = schema_version
      @validator = validator
      @schema_generator = schema_generator
    end

    def generate(request_file, host)
      contract = Pacto.build_from_file request_file, host
      request = contract.request
      response = request.execute
      save(request, response)
    end

    def save(request, response)
      body_schema = JSON::SchemaGenerator.generate response, @schema_version
      contract = {
        :request => {
          :headers => request.headers,
          :method => request.method,
          :params => request.params,
          :path => request.path
        },
        :response => {
          :headers => response.headers,
          :status => response.status,
          :body => body_schema
        }
      }
      pretty_contract = JSON.pretty_generate(contract)
      @validator.validate pretty_contract
      pretty_contract
    end
  end
end
