require "contracts/version"

require "json"
require "json-generator"
require "webmock"
require "ostruct"

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
    registered[contract_name].instantiate(values).stub!
  end

  def self.registered
    @registered ||= {}
  end
end
