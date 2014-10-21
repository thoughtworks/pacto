require 'swagger'

module Pacto
  # Builds {Pacto::Contract} instances from Swagger documents
  class SwaggerContractFactory
    include Logger

    def load_hints(contract_path, host = nil)
      app = Swagger.load(contract_path)
      app.operations.map do |op|
        Pacto::Generator::Hint.new(request_clause_hash(op, host).merge(
          service_name: op.fetch(:summary)
        ))
      end
    end

    def build_from_file(contract_path, host = nil)
      app = Swagger.load(contract_path)
      app.operations.map do |op|
        default_response = op.default_response
        request = Pacto::RequestClause.new(request_clause_hash(op, host))
        response = Pacto::ResponseClause.new(response_clause_hash(op, default_response, host))
        Contract.new(
          name: op.full_name,
          file: contract_path,
          request: request, response: response,
          examples: build_examples(op, default_response)
        )
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

    def request_clause_hash(op, host)
      {
        host: op.host || host,
        http_method: op.verb,
        path: op.path
      }
    end

    def response_clause_hash(op, response, _host)
      if response.nil?
        logger.warn("No response defined for #{op.full_name}")
        return Pacto::ResponseClause.new(status: 200)
      end

      {}.tap do | response_clause |
        response_clause[:status] = response.status_code || 200
        response_clause[:schema] = response.schema.parse unless response.schema.nil?
      end
    end

    def build_examples(op, response)
      return nil if response.nil? || response.examples.nil? || response.examples.empty?

      {
        default: {
          request: {}, # Swagger doesn't have a clear way to capture request examples
          response: {
            body: response.examples.values.first.parse
          }
        }
      }
    rescue => e # FIXME: Only parsing errors?
      logger.warn("Error while trying to parse response example for #{op.full_name}")
      logger.debug("  Error details: #{e.inspect}")
      nil
    end
  end
end

Pacto::ContractFactory.add_factory(:swagger, Pacto::SwaggerContractFactory.new)
