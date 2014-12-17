# -*- encoding : utf-8 -*-
require 'swagger'
require 'pacto/swagger_contract'

module Pacto
  # Builds {Pacto::SwaggerContract} instances from Swagger documents
  class SwaggerContractFactory
    include Logger

    def load_hints(contract_path, host = nil)
      app = ::Swagger.load(contract_path)
      app.operations.map do |op|
        request_clause = Pacto::Swagger::RequestClause.new(op, host: host)
        Pacto::Generator::Hint.new(request_clause.to_hash.merge(
          service_name: op.fetch(:summary)
        ))
      end
    end

    def build_from_file(contract_path, host = nil)
      app = ::Swagger.load(contract_path)
      app.operations.map do |op|
        SwaggerContract.new(op,
                            file: contract_path,
                            host: host
        )
      end
    rescue ArgumentError => e
      raise "Could not load #{contract_path}: #{e.message}"
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
  end
end

Pacto::ContractFactory.add_factory(:swagger, Pacto::SwaggerContractFactory.new)
