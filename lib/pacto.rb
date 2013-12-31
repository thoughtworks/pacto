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
require 'pacto/core/callback'
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
require 'pacto/erb_processor'
require 'pacto/hash_merge_processor'
require 'pacto/stubs/built_in'
require 'pacto/meta_schema'
require 'pacto/hooks/erb_hook'
require 'pacto/generator'
require 'pacto/generator/filters'

# Validators
require 'pacto/validators/response_status_validator'
require 'pacto/validators/response_header_validator'
require 'pacto/validators/response_body_validator'

module Pacto
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def contract_registry
      @list ||= ContractRegistry.new
    end

    def clear!
      Pacto.configuration.provider.reset!
      @modes = nil
      @configuration = nil
      contract_registry.unregister_all!
      Pacto::ValidationRegistry.instance.reset!
    end

    def configure
      yield(configuration)
    end

    def register_contract(contract, tags)
      contract_registry.register_contract(contract, tags)
    end

    def contracts_for(request_signature)
      contract_registry.contracts_for(request_signature)
    end

    def contract_for(request_signature)
      contract_registry.contract_for(request_signature)
    end

    def load_all(contracts_directory, host, *tags)
      Pacto::Utils.all_contract_files_on(contracts_directory).each { |file| load file, host, *tags }
    end

    def load(contract_file, host, *tags)
      Logger.instance.debug "Registering #{contract_file} with #{tags}"
      contract = ContractFactory.build_from_file contract_file, host, nil
      contract_registry.register_contract contract, *tags
    end

    def use(tag, values = {})
      contract_registry.use(tag, values)
    end
  end

  def self.validate_contract(contract)
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

  def self.build_from_file(contract_path, host, file_pre_processor = Pacto.configuration.preprocessor)
    ContractFactory.build_from_file(contract_path, host, file_pre_processor)
  end
end
