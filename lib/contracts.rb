require "contracts/version"

require "hash_deep_merge"
require "json"
require "json-schema"
require "json-generator"
require "webmock"
require "ostruct"

require "contracts/extensions"
require "contracts/request"
require "contracts/response"
require "contracts/instantiated_contract"
require "contracts/contract"

module Contracts
  def self.build_from_file(contract_path, host)
    definition = JSON.parse(File.read(contract_path))
    request = Request.new(host, definition["request"])
    response = Response.new(definition["response"])
    Contract.new(request, response)
  end

  def self.register(name, contract)
    registered[name] = contract
  end

  def self.use(contract_name, values = {})
    raise ArgumentError unless registered.has_key?(contract_name)
    instantiated_contract = registered[contract_name].instantiate(values)
    instantiated_contract.stub!
    instantiated_contract.response_body
  end

  def self.registered
    @registered ||= {}
  end
end
