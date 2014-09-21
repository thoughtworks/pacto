require 'swagger'

module Pacto
  # Builds {Pacto::Contract} instances from Swagger documents
  class SwaggerContractFactory
    def load_hints(contract_path, host = nil)
      app = Swagger.load(contract_path)
      app.apis.map do |api|
        Pacto::Generator::Hint.new(request_clause_hash(api, host).merge(
          service_name: api.fetch(:operationId)
        ))
      end
    end

    def build_from_file(contract_path, host = nil)
      app = Swagger.load(contract_path)
      app.apis.map do |api|
        request = Pacto::RequestClause.new(request_clause_hash(api, host))
        response = Pacto::ResponseClause.new(response_clause_hash(api, host))
        Contract.new(request: request, response: response, file: contract_path)
        # , name: definition['name'], examples: definition['examples'])
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
        response_clause[:status] = response.status_code
        response_clause[:schema] = response.schema.parse unless response.schema.nil?
      end
    end
  end
end
