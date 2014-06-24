require 'json/schema_generator'

module Pacto
  class Generator
    include Logger

    def initialize(schema_version = 'draft3',
      schema_generator = JSON::SchemaGenerator,
      validator = Pacto::MetaSchema.new,
      filters = Pacto::Generator::Filters.new)
      @schema_version = schema_version
      @validator = validator
      @schema_generator = schema_generator
      @filters = filters
    end

    def generate(pacto_request, pacto_response)
      return unless Pacto.generating?
      logger.debug("Generating Contract for #{pacto_request}, #{pacto_response}")
      begin
        contract_file = load_contract_file(pacto_request)

        unless File.exist? contract_file
          uri = URI(pacto_request.uri)
          FileUtils.mkdir_p(File.dirname contract_file)
          File.write(contract_file, save(uri, pacto_request, pacto_response))
          logger.debug("Generating #{contract_file}")

          Pacto.load_contract contract_file, uri.host
        end
      rescue => e
        logger.error("Error while generating Contract #{contract_file}: #{e.message}")
        logger.error("Backtrace: #{e.backtrace}")
      end
    end

    def generate_from_partial_contract(request_file, host)
      contract = Pacto.load_contract request_file, host
      request, response = contract.execute
      save(request_file, request, response)
    end

    def save(source, request, response)
      contract = generate_contract source, request, response
      pretty_contract = MultiJson.encode(contract, :pretty => true)
      # This is because of a discrepency w/ jruby vs MRI pretty json
      pretty_contract.gsub!(/^$\n/, '')
      @validator.validate pretty_contract
      pretty_contract
    end

    private

    def generate_contract(source, request, response)
      {
        :request => generate_request(request, response, source),
        :response => generate_response(request, response, source)
      }
    end

    def generate_request(request, response, source)
      {
        :headers => @filters.filter_request_headers(request, response),
        :http_method => request.method,
        :params => request.uri.query_values,
        :path => request.uri.path,
        :schema => generate_schema(source, request.body)
      }.delete_if { |_k, v| v.nil? }
    end

    def generate_response(request, response, source)
      {
        :headers => @filters.filter_response_headers(request, response),
        :status => response.status,
        :schema => generate_schema(source, response.body)
      }.delete_if { |_k, v| v.nil? }
    end

    def generate_schema(source, body, generator_options = Pacto.configuration.generator_options)
      return if body.nil? || body.empty?

      body_schema = JSON::SchemaGenerator.generate source, body, generator_options
      MultiJson.load(body_schema)
    end

    def load_contract_file(pacto_request)
      uri = URI(pacto_request.uri)
      path = uri.path
      basename = File.basename(path, '.json') + '.json'
      File.join(Pacto.configuration.contracts_path, uri.host, File.dirname(path), basename)
    end
  end
end
