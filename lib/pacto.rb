require 'pacto/version'

require 'addressable/template'
require 'middleware'
require 'faraday'
require 'hash_deep_merge'
require 'multi_json'
require 'json-schema'
require 'json-generator'
require 'webmock'
require 'ostruct'
require 'erb'
require 'logger'

require 'pacto/utils'
require 'pacto/ui'
require 'pacto/core/contract_registry'
require 'pacto/core/validation_registry'
require 'pacto/core/configuration'
require 'pacto/core/modes'
require 'pacto/core/hook'
require 'pacto/logger'
require 'pacto/exceptions/invalid_contract.rb'
require 'pacto/extensions'
require 'pacto/request'
require 'pacto/response'
require 'pacto/stubs/built_in'
require 'pacto/contract'
require 'pacto/contract_validator'
require 'pacto/contract_factory'
require 'pacto/validation'
require 'pacto/stubs/built_in'
require 'pacto/meta_schema'
require 'pacto/hooks/erb_hook'
require 'pacto/generator'
require 'pacto/generator/filters'
require 'pacto/contract_files'
require 'pacto/contract_list'

# Validators
require 'pacto/validators/response_status_validator'
require 'pacto/validators/response_header_validator'
require 'pacto/validators/response_body_validator'

module Pacto
  class << self
    def contract_factory
      @factory = ContractFactory.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def contract_registry
      @registry ||= ContractRegistry.new
    end

    def clear!
      Pacto.configuration.provider.reset!
      @modes = nil
      @configuration = nil
      @registry = nil
      Pacto::ValidationRegistry.instance.reset!
    end

    def configure
      yield(configuration)
    end

    def load_all(contracts_directory, host, *tags)
      Pacto::Utils.all_contract_files_on(contracts_directory).each { |file| load file, host, *tags }
    end

    def load(contract_file, host, *tags)
      Logger.instance.debug "Registering #{contract_file} with #{tags}"
      contract = contract_factory.build_from_file contract_file, host
      contract_registry.register contract, *tags
    end

    def register_contract(contract, tags)
      contract_registry.register(contract, tags)
    end

    def contracts_for(request_signature)
      contract_registry.contracts_for(request_signature)
    end

    def use(tag, values = {})
      contract_registry.use(tag, values)
    end

    def validate_contract(contract)
      Pacto::MetaSchema.new.validate contract
      puts "Validating #{contract}"
      true
    rescue InvalidContract => exception
      puts 'Validation errors detected'
      exception.errors.each do |error|
        puts "  Error: #{error}"
      end
      false
    end

    def build_from_file(contract_path, host)
      contract_factory.build_from_file(contract_path, host)
    end

    def build_contracts(contracts_path, host)
      files = ContractFiles.for(contracts_path)
      contracts = contract_factory.build(files, host)
      ContractList.new(contracts)
    end
  end
end
