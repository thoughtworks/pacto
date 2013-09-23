require "pacto/version"

require "httparty"
require "hash_deep_merge"
require "json"
require "json-schema"
require "json-generator"
require "webmock"
require "ostruct"
require "erb"

require "pacto/exceptions/invalid_contract.rb"
require "pacto/extensions"
require "pacto/request"
require "pacto/response_adapter"
require "pacto/response"
require "pacto/stubs/built_in"
require "pacto/stubs/stub_provider"
require "pacto/instantiated_contract"
require "pacto/contract"
require "pacto/contract_factory"
require "pacto/erb_processor"
require "pacto/hash_merge_processor"
require "pacto/stubs/built_in"
require "pacto/configuration"
require "pacto/meta_schema"

module Pacto
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  def self.validate_contract contract
    begin
      Pacto::MetaSchema.new.validate contract
      puts "All contracts successfully meta-validated"
      true
    rescue InvalidContract => e
      puts "Validation errors detected"
      e.errors.each do |e|
        puts "  Error: #{e}"
      end
      false
    end
  end

  def self.build_from_file(contract_path, host, file_pre_processor=Pacto.configuration.preprocessor)
    ContractFactory.build_from_file(contract_path, host, file_pre_processor)
  end

  def self.register(&block)
    yield self
  end

  def self.register_contract(contract = nil, *tags)
    tags.uniq.each do |tag| 
      registered[tag] << contract
    end
    nil
  end

  def self.use(tag, values = nil)
    merged_contracts = registered[:default].merge registered[tag]

    raise ArgumentError, "contract \"#{tag}\" not found" if merged_contracts.empty?
    
    configuration.provider.values = values    

    merged_contracts.inject(Set.new) do |result, contract|
      instantiated_contract = contract.instantiate
      instantiated_contract.stub!
      result << instantiated_contract
    end
  end
  
  def self.load(contract_name)
    build_from_file(path_for(contract_name), nil)
  end

  def self.registered
    @registered ||= Hash.new { |hash, key| hash[key] = Set.new }
  end

  def self.unregister_all!
    registered.clear
  end
  
  private
  def self.path_for(contract)
    File.join(configuration.contracts_path, "#{contract}.json")
  end
end
