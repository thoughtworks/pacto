module Pacto
  class ContractBuilder < Hashie::Dash
    attr_accessor :source

    def initialize(options = {})
      @schema_generator = options[:schema_generator] ||= JSON::SchemaGenerator
      @filters = options[:filters] ||= Pacto::Generator::Filters.new
      @data = { request: {}, response: {}, examples: {} }
      @source = 'Pacto' # Currently used by JSONSchemaGeneator, but not really useful
    end

    def name=(service_name)
      @data[:name] = service_name
    end

    def add_example(name, pacto_request, pacto_response)
      @data[:examples][name] ||= {}
      @data[:examples][name][:request] = clean(pacto_request.to_hash)
      @data[:examples][name][:response] = clean(pacto_response.to_hash)
    end

    def infer_schemas
      # TODO: It'd be awesome if we could infer across all examples
      return self if @data[:examples].empty?

      example = @data[:examples].values.first
      sample_request_body = example[:request][:body]
      sample_response_body = example[:response][:body]
      @data[:request][:schema] = generate_schema(sample_request_body) if sample_request_body
      @data[:response][:schema] = generate_schema(sample_response_body) if sample_response_body
      self
    end

    def without_examples
      @export_examples = false
      self
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
      request = clean(
                        headers: @filters.filter_request_headers(request, response),
                        http_method: request.method,
                        params: request.uri.query_values,
                        path: request.uri.path
                      )
      @data[:request] = request
      self
    end

    def generate_response(request, response)
      response = clean(
                         headers: @filters.filter_response_headers(request, response),
                         status: response.status
                       )
      @data[:response] = response
      self
    end

    def build_hash
      instance_eval(&block) if block_given?
      @final_data = @data.dup
      @final_data.delete(:examples) if exclude_examples?
      clean(@final_data)
    end

    def build(&block)
      Contract.new build_hash(&block)
    end

    protected

    def exclude_examples?
      @export_examples == false
    end

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
