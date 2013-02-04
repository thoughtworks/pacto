require "contracts/version"

require "json"
require "json-generator"

require "contracts/object_properties"
require "contracts/basic_attribute"
require "contracts/string_attribute"
require "contracts/integer_attribute"
require "contracts/array_attribute"
require "contracts/object_attribute"
require "contracts/attribute_factory"
require "contracts/request"
require "contracts/response"
require "contracts/instantiated_contract"
require "contracts/contract"

module Contracts
  def self.register(contract_name, contract_path)
    definition = JSON.parse(File.read(contract_path))
    request = Request.new(definition["request"])
    response = Response.new(definition["response"])
    registered[contract_name] = Contract.new(request, response)
  end

  def self.use(contract_name, values = {})
    raise ArgumentError unless registered.has_key?(contract_name)
    instantiated[contract_name] = registered[contract_name].instantiate(values)
  end

  def self.reset!
    @instantiated = {}
  end

  def self.registered
    @registered ||= {}
  end

  def self.instantiated
    @instantiated ||= {}
  end
end
