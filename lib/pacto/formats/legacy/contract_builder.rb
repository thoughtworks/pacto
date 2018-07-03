# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Legacy
      class ContractBuilder < Hashie::Dash # rubocop:disable Metrics/ClassLength
        extend Forwardable
        attr_accessor :source

        def initialize(options = {})
          @schema_generator = options[:schema_generator] ||= JSON::SchemaGenerator
          @filters = options[:filters] ||= Generator::Filters.new
          @data = { request: {}, response: {}, examples: {} }
          @source = 'Pacto' # Currently used by JSONSchemaGeneator, but not really useful
        end

        def name=(name)
          @data[:name] = name
        end

        def add_example(name, pacto_request, pacto_response)
          @data[:examples][name] ||= {}
          @data[:examples][name][:request] = clean(pacto_request.to_hash)
          @data[:examples][name][:response] = clean(pacto_response.to_hash)
          self
        end

        def infer_all
          # infer_file # The target file is being chosen inferred by the Generator
          infer_name
          infer_schemas
        end

        def infer_name
          if @data[:examples].empty?
            @data[:name] = @data[:request][:path] if @data[:request]
            return self
          end

          example, hint = example_and_hint
          @data[:name] = hint.nil? ? PactoRequest.new(example[:request]).uri.path : hint.service_name
          self
        end

        def infer_schemas
          return self if @data[:examples].empty?

          # TODO: It'd be awesome if we could infer across all examples
          example, _hint = example_and_hint
          sample_request_body = example[:request][:body]
          sample_response_body = example[:response][:body]
          @data[:request][:schema] = generate_schema(sample_request_body) if sample_request_body && !sample_request_body.empty?
          @data[:response][:schema] = generate_schema(sample_response_body) if sample_response_body && !sample_response_body.empty?
          self
        end

        def without_examples
          @export_examples = false
          self
        end

        def generate_contract(request, response)
          generate_request(request, response)
          generate_response(request, response)
          infer_all
          self
        end

        def generate_request(request, response)
          hint = hint_for(request)
          request = clean(
                            headers: @filters.filter_request_headers(request, response),
                            http_method: request.method,
                            params: request.uri.query_values,
                            path: hint.nil? ? parse_path(request) : hint.path
                          )
          @data[:request] = request
          self
        end

        def parse_path(request)
          return request.uri.path unless get_request_with_query? request
          request.uri.path + "?" + request.uri.query
        end

        def get_request_with_query?(request)
          request.method.to_s == "get" && request.uri.query
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

        def example_and_hint
          example = @data[:examples].values.first
          example_request = PactoRequest.new example[:request]
          [example, Pacto::Generator.hint_for(example_request)]
        end

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

        def hint_for(pacto_request)
          Pacto::Generator.hint_for(pacto_request)
        end
      end
    end
  end
end
