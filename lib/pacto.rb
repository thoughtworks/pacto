# -*- encoding : utf-8 -*-
require 'pacto/version'

require 'addressable/template'
require 'swagger'
require 'middleware'
require 'faraday'
require 'multi_json'
require 'json-schema'
require 'json-generator'
require 'webmock'
require 'ostruct'
require 'erb'
require 'logger'

# FIXME: There's soo much stuff here! I'd both like to re-roganize and to use autoloading.
require 'pacto/errors'
require 'pacto/dash'
require 'pacto/resettable'
require 'pacto/logger'
require 'pacto/ui'
require 'pacto/request_pattern'
require 'pacto/core/http_middleware'
require 'pacto/consumer/faraday_driver'
require 'pacto/actor'
require 'pacto/consumer'
require 'pacto/provider'
require 'pacto/actors/json_generator'
require 'pacto/actors/from_examples'
require 'pacto/body_parsing'
require 'pacto/core/pacto_request'
require 'pacto/core/pacto_response'
require 'pacto/core/contract_registry'
require 'pacto/core/investigation_registry'
require 'pacto/core/configuration'
require 'pacto/core/modes'
require 'pacto/core/hook'
require 'pacto/extensions'
require 'pacto/request_clause'
require 'pacto/response_clause'
require 'pacto/stubs/webmock_adapter'
require 'pacto/stubs/uri_pattern'
require 'pacto/contract'
require 'pacto/cops'
require 'pacto/meta_schema'
require 'pacto/contract_factory'
require 'pacto/investigation'
require 'pacto/hooks/erb_hook'
require 'pacto/observers/stenographer'
require 'pacto/generator'
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
    def configuration
      @configuration ||= Configuration.new
    end

    def contract_registry
      @registry ||= ContractRegistry.new
    end

    # Resets data and metrics only. It usually makes sense to call this between test scenarios.
    def reset
      Pacto::InvestigationRegistry.instance.reset!
      # Pacto::Resettable.reset_all
    end

    # Resets but also clears configuration, loaded contracts, and plugins.
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

    # @throws Pacto::InvalidContract
    def validate_contract(contract)
      Pacto::MetaSchema.new.validate contract
      true
    end

    def load_contract(contract_path, host, format = :legacy)
      load_contracts(contract_path, host, format).first
    end

    def load_contracts(contracts_path, host, format = :legacy)
      contracts = ContractFactory.load_contracts(contracts_path, host, format)
      contracts.each do |contract|
        contract_registry.register(contract)
      end
      ContractSet.new(contracts)
    end
  end
end
