require 'json/schema_generator'

module Pacto
  class Generator
    attr_accessor :response_headers_to_filter

    INFORMATIONAL_RESPONSE_HEADERS =
    %w{
      server
      date
      content-length
      connection
    }

    def initialize(schema_version = 'draft3',
      schema_generator = JSON::SchemaGenerator,
      validator = Pacto::MetaSchema.new)
      @schema_version = schema_version
      @validator = validator
      @schema_generator = schema_generator
      @response_headers_to_filter = INFORMATIONAL_RESPONSE_HEADERS
    end

    def generate(request_file, host)
      contract = Pacto.build_from_file request_file, host
      raw_contract = Pacto.build_from_file request_file, host, nil
      request = raw_contract.request
      response = contract.request.execute
      save(request_file, request, response)
    end

    def save(source, request, response)
      @vary_string = response.headers['vary'] || ''
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
        :request => generate_request(request),
        :response => generate_response(response, source)
      }
    end

    def generate_request request
      {
        :headers => filter_request_headers(request.headers),
        :method => request.method,
        :params => request.params,
        :path => request.path
      }
    end

    def generate_response response, source
      {
        :headers => filter_response_headers(response.headers),
        :status => response.status,
        :body => generate_body(source, response.body)
      }
    end

    def generate_body source, body
      body_schema = JSON::SchemaGenerator.generate source, body, @schema_version
      MultiJson.load(body_schema)
    end

    def filter_request_headers headers
      vary_headers = @vary_string.split ','
      headers.select do |header|
        vary_headers.map(&:downcase).include? header.downcase
      end
    end

    def filter_response_headers headers
      headers.reject do |header|
        @response_headers_to_filter.include? header.downcase
      end
    end
  end
end
