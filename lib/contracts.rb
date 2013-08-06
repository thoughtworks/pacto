require "contracts/version"

require "httparty"
require "hash_deep_merge"
require "json"
require "json-schema"
require "json-generator"
require "webmock"
require "ostruct"
require "erb"

require "contracts/extensions"
require "contracts/request"
require "contracts/response_adapter"
require "contracts/response"
require "contracts/instantiated_contract"
require "contracts/contract"
require "contracts/file_pre_processor"

module Contracts
  def self.build_from_file(contract_path, host, file_pre_processor=FilePreProcessor.new)
    contract_definition_expanded = file_pre_processor.process(File.read(contract_path))
    definition = JSON.parse(contract_definition_expanded)
    request = Request.new(host, definition["request"])
    response = Response.new(definition["response"])
    Contract.new(request, response)
  end

  def self.register(name, contract)
    raise ArgumentError, "contract \" #{name}\" has already been registered" if registered.has_key?(name)
    registered[name] = contract
  end

  def self.use(contract_name, values = nil)
    raise ArgumentError, "contract \"#{contract_name}\" not found" unless registered.has_key?(contract_name)
    instantiated_contract = registered[contract_name].instantiate(values)
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
