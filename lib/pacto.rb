require 'pacto/version'

require 'addressable/template'
require 'middleware'
require 'faraday'
require 'multi_json'
require 'json-schema'
require 'json-generator'
require 'webmock'
require 'ostruct'
require 'erb'
require 'logger'
require 'hashie/dash'
require 'hashie/extensions/coercion'

require 'pacto/resettable'
require 'pacto/logger'
require 'pacto/ui'
require 'pacto/request_pattern'
require 'pacto/core/http_middleware'
require 'pacto/consumer/faraday_driver'
require 'pacto/consumer'
require 'pacto/provider'
require 'pacto/actors/json_generator'
require 'pacto/actors/from_examples'
require 'pacto/core/pacto_request'
require 'pacto/core/pacto_response'
require 'pacto/core/contract_registry'
require 'pacto/core/investigation_registry'
require 'pacto/core/configuration'
require 'pacto/core/modes'
require 'pacto/core/hook'
require 'pacto/exceptions/invalid_contract.rb'
require 'pacto/extensions'
require 'pacto/request_clause'
require 'pacto/response_clause'
require 'pacto/stubs/webmock_adapter'
require 'pacto/stubs/uri_pattern'
require 'pacto/contract'
require 'pacto/cops'
require 'pacto/contract_factory'
require 'pacto/investigation'
require 'pacto/meta_schema'
require 'pacto/hooks/erb_hook'
require 'pacto/observers/stenographer'
require 'pacto/generator'
require 'pacto/generator/filters'
require 'pacto/contract_files'
require 'pacto/contract_set'
require 'pacto/uri'

# Cops
require 'pacto/cops/body_cop'
require 'pacto/cops/request_body_cop'
require 'pacto/cops/response_body_cop'
require 'pacto/cops/response_status_cop'
require 'pacto/cops/response_header_cop'

module Pacto
  class << self
    def contract_factory
      @factory ||= ContractFactory.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def contract_registry
      @registry ||= ContractRegistry.new
    end

    def clear!
      Pacto::Resettable.reset_all
      @modes = nil
      @configuration = nil
      @registry = nil
    end

    def configure
      yield(configuration)
    end

    def contracts_for(request_signature)
      contract_registry.contracts_for(request_signature)
    end

    def validate_contract(contract)
      Pacto::MetaSchema.new.validate contract
      puts "Validating #{contract}"
      true
    rescue InvalidContract => exception
      puts 'Investigation errors detected'
      exception.errors.each do |error|
        puts "  Error: #{error}"
      end
      false
    end

    def load_contract(contract_path, host, format = :default)
      load_contracts(contract_path, host, format).first
    end

    def load_contracts(contracts_path, host, format = :default)
      files = ContractFiles.for(contracts_path)
      contracts = contract_factory.build(files, host, format)
      contracts.each do |contract|
        contract_registry.register(contract)
      end
      ContractSet.new(contracts)
    end
  end
end
