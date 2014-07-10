module Pacto
  class ContractBuilder < Hashie::Dash
    attr_accessor :source

    def initialize(options = {})
      @schema_generator = options[:schema_generator] ||= JSON::SchemaGenerator
      @filters = options[:filters] ||= Pacto::Generator::Filters.new
      @data = {}
      @source = 'Pacto' # Currently used by JSONSchemaGeneator, but not really useful
    end

    # def add_example(name, pacto_request, pacto_response)
    # end

    # def add_request_header(name, value)
    # end

    # def add_response_header(name, value)
    # end

    def name=(service_name)
      @data[:name] = service_name
    end

    def generate_contract(request, response)
      # if hint
      #   @data[:name] = hint.service_name
      # else
        @data[:name] = request.uri.path
      # end
      generate_request(request, response)
      generate_response(request, response)
      self
    end

    def generate_request(request, response)
      request = clean({
        headers: @filters.filter_request_headers(request, response),
        http_method: request.method,
        params: request.uri.query_values,
        path: request.uri.path,
        schema: generate_schema(request.body)
      })
      @data[:request] = request
      self
    end

    def generate_response(request, response)
      response = clean({
        headers: @filters.filter_response_headers(request, response),
        status: response.status,
        schema: generate_schema(response.body)
      })
      @data[:response] = response
      self
    end

    def build_hash
      instance_eval &block if block_given?
      clean(@data)
    end

    def build(&block)
      Contract.new build_hash(&block)
    end

    protected

    def generate_schema(body, generator_options = Pacto.configuration.generator_options)
      return if body.nil? || body.empty?

      body_schema = @schema_generator.generate @source, body, generator_options
      MultiJson.load(body_schema)
    end

    def clean(data)
      data.delete_if { |_k, v| v.nil? }
    end
  end
end
