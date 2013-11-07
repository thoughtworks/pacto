require 'pacto/version'

require 'httparty'
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
require 'pacto/core/contract_repository'
require 'pacto/core/configuration'
require 'pacto/core/modes'
require 'pacto/core/callback'
require 'pacto/logger'
require 'pacto/exceptions/invalid_contract.rb'
require 'pacto/extensions'
require 'pacto/request'
require 'pacto/response_adapter'
require 'pacto/response'
require 'pacto/stubs/built_in'
require 'pacto/contract'
require 'pacto/contract_factory'
require 'pacto/erb_processor'
require 'pacto/hash_merge_processor'
require 'pacto/stubs/built_in'
require 'pacto/meta_schema'
require 'pacto/hooks/erb_hook'
require 'pacto/generator'
require 'pacto/generator/filters'

module Pacto
  class << self

    def configuration
      @configuration ||= Configuration.new
    end

    def clear!
      Pacto.configuration.provider.reset!
      @modes = nil
      @configuration = nil
      unregister_all!
    end

    def configure
      yield(configuration)
    end
  end

  def self.validate_contract contract
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
