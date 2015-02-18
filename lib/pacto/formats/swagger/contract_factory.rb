# -*- encoding : utf-8 -*-
require 'swagger'
require 'pacto/formats/swagger/contract'

module Pacto
  module Formats
    module Swagger
      # Builds {Pacto::Formats::Swagger::Contract} instances from Swagger documents
      class ContractFactory
        include Logger

        def load_hints(_contract_path, _host = nil)
          fail NotImplementedError, 'Contract generation from hints is not currently supported for Swagger'
        end

        def build_from_file(contract_path, host = nil)
          app = ::Swagger.load(contract_path)
          app.operations.map do |op|
            Contract.new(op,
                         file: contract_path,
                         host: host
            )
          end
        rescue ArgumentError => e
          logger.error(e)
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
      Pacto::ContractFactory.add_factory(:swagger, ContractFactory.new)
    end
  end
end
