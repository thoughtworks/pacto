require 'swagger'

module Pacto
  # Builds {Pacto::Contract} instances from Swagger documents
  class SwaggerContractFactory
    include Logger

    def load_hints(contract_path, host = nil)
      app = Swagger.load(contract_path)
      app.apis.map do |api|
        Pacto::Generator::Hint.new(request_clause_hash(api, host).merge(
          service_name: api.fetch(:summary)
        ))
      end
    end

    def build_from_file(contract_path, host = nil)
      app = Swagger.load(contract_path)
      app.apis.map do |api|
        request = Pacto::RequestClause.new(request_clause_hash(api, host))
        response = Pacto::ResponseClause.new(response_clause_hash(api, host))
        Contract.new(
          name: "#{api.root.info.title} :: #{api.summary}",
          file: contract_path,
          request: request, response: response,
          examples: build_examples(api)
        )
        # , name: definition['name'], examples: definition['examples'])
      end
    end

    def files_for(contracts_dir)
      full_path = Pathname.new(contracts_dir).realpath

      if  full_path.directory?
        all_json_files = "#{full_path}/**/*.{json,yaml,yml}"
        Dir.glob(all_json_files).map do |f|
          Pathname.new(f)
        end
      else
        [full_path]
      end
    end

    private

    def request_clause_hash(api, host)
      {
        host: api.host || host,
        http_method: api.verb,
        path: api.path
      }
    end

    def response_clause_hash(api, _host)
      response = api.default_response
      {}.tap do | response_clause |
        if response.nil?
          logger.warn("No response defined for #{api.operationId}")
          response_clause[:status] = 200
        else
          response_clause[:status] = response.status_code || 200
          response_clause[:schema] = response.schema.parse unless response.schema.nil?
        end
      end
    end

    def build_examples(api)
      examples = api.default_response.examples
      return nil if examples.nil? || examples.empty?
      {
        default: {
          request: {}, # Swagger doesn't have a clear way to capture request examples
          response: {
            body: api.default_response.examples.values.first.parse
          }
        }
      }
    rescue => e
      logger.warn("Error while trying to parse response example: #{e.inspect}")
      nil
    end
  end
end

Pacto::ContractFactory.add_factory(:swagger, Pacto::SwaggerContractFactory.new)
