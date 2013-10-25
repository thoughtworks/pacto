require 'json/schema_generator'

module Pacto
  class Generator
    attr_accessor :request_headers_to_filter
    attr_accessor :response_headers_to_filter

    INFORMATIONAL_REQUEST_HEADERS =
    %w{
      content-length
      via
    }

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
      @request_headers_to_filter = INFORMATIONAL_REQUEST_HEADERS
    end

    def generate(request_file, host)
      contract = Pacto.build_from_file request_file, host
      raw_contract = Pacto.build_from_file request_file, host, nil
      request = raw_contract.request
      response = contract.request.execute
      save(request_file, request, response)
    end

    def save(source, request, response)
      body_schema = JSON::SchemaGenerator.generate source, response.body, @schema_version
      contract = {
        :request => {
          :headers => filter_request_headers(request.headers),
          :method => request.method,
          :params => request.params,
          :path => request.path
        },
        :response => {
          :headers => filter_response_headers(response.headers),
          :status => response.status,
          :body => MultiJson.load(body_schema)
        }
      }
      pretty_contract = MultiJson.encode(contract, :pretty => true)
      # This is because of a discrepency w/ jruby vs MRI pretty json
      pretty_contract.gsub! /^$\n/, ''
      @validator.validate pretty_contract
      pretty_contract
    end

    private

    def filter_request_headers headers
      headers.reject do |header|
        @request_headers_to_filter.include? header.downcase
      end
    end

    def filter_response_headers headers
      headers.reject do |header|
        @response_headers_to_filter.include? header.downcase
      end
    end
  end
end
