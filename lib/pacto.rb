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
require "pacto/file_pre_processor"

module Pacto
  def self.build_from_file(contract_path, host, file_pre_processor=FilePreProcessor.new)
    ContractFactory.build_from_file(contract_path, host, file_pre_processor)
  end

  def self.register(&block)
    yield self
  end

  def self.register_contract(contract = nil, *tags, &block)
    tags.uniq.each do |tag| 
      registered[tag] << contract
    end
    nil
  end

  def self.use(tag, values = nil)
    raise ArgumentError, "contract \"#{tag}\" not found" unless registered.has_key?(tag)
    registered[tag].inject(Set.new) do |result, contract|
     instantiated_contract = contract.instantiate(values)
     instantiated_contract.stub!
     result << instantiated_contract
   end
  end

  def self.registered
    @registered ||= Hash.new { |hash, key| hash[key] = Set.new }
  end

  def self.unregister_all!
    @registered = nil
  end
end
