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

  def self.register(contract, contract_tag)
    raise ArgumentError, "contract \"#{contract_tag}\" has already been registered" if registered.has_key?(contract_tag)
    registered[contract_tag] = contract
  end

  def self.use(contract_tag, values = nil)
    raise ArgumentError, "contract \"#{contract_tag}\" not found" unless registered.has_key?(contract_tag)
    instantiated_contract = registered[contract_tag].instantiate(values)
    instantiated_contract.stub!
    instantiated_contract
  end

  def self.registered
    @registered ||= {}
  end

  def self.unregister_all!
    @registered = {}
  end
end
