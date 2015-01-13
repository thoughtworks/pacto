# -*- encoding : utf-8 -*-
require 'pacto'
require 'hashie/mash'

# Fabricators for contracts or parts of contracts

Fabricator(:swagger_contract, from: Pacto::SwaggerContract) do
  initialize_with do
    data = @_attributes.merge(@_transient_attributes)
    swagger_api_obj = data.delete(:swagger_api)
    api_data = data.dup.keep_if { |k| [:file].include? k }
    swagger_api_obj ||= Fabricate(:swagger_api, api_data)
    if data[:request]
      api_operation_data = data[:request].to_hash.merge(api: swagger_api_obj)
      api_operation_data.keep_if { |k| ['path', 'params', 'http_method', 'headers', :api].include? k }
    else
      api_operation_data = {}
    end
    swagger_api_operation = Fabricate(:swagger_api_operation, api_operation_data)
    @_klass.new swagger_api_operation, {} # to_hash
  end
  transient example_count: 0
  transient name: 'Dummy Contract'
  transient trafile: 'file:///does/not/exist/swagger.yaml'
  transient :swagger_api
  transient :swagger_api_operation
  transient :request
  transient :response

  after_build do | swagger_contract, transients |
    if transients[:example_count]
      examples = transients[:example_count].times.each_with_object({}) do |i, h|
        name = i.to_s
        h[name] = Fabricate(:swagger_an_example, name: name)
      end
      swagger_contract.examples = examples
    else
      nil
    end
  end
end

Fabricator(:swagger_partial_contract, from: Pacto::Generator::Hint) do
  initialize_with do
    request = @_transient_attributes[:request]
    request ||= Fabricate(:swagger_request_clause)
    @_klass.new request.to_hash.merge(
      service_name: name,
      target_file: file
    )
  end
  name { 'Dummy Contract' }
  file { 'file:///does/not/exist/swagger.yaml' }
  transient :request
end

Fabricator(:swagger_request_clause, from: Pacto::Swagger::RequestClause) do
  initialize_with do
    data = @_attributes.merge(@_transient_attributes)
    swagger_api_operation = data.delete :swagger_api_operation
    host = data.delete :host
    swagger_api_operation ||= Fabricate(:swagger_api_operation, data)
    @_klass.new swagger_api_operation, host: host
  end

  transient :swagger_api_operation
  transient host: 'example.com'
  transient http_method: 'GET'
  transient path: '/abcd'
  transient headers: {
    'Server' => ['example.com'],
    'Connection' => ['Close'],
    'Content-Length' => [1234],
    'Via' => ['Some Proxy'],
    'User-Agent' => ['rspec']
  }
  transient params: {}
  transient schema: {}
end

Fabricator(:swagger_response_clause, from: Pacto::Swagger::ResponseClause) do
  initialize_with do
    swagger_response = _transient_attributes[:swagger_response]
    headers = @_transient_attributes[:headers].each_with_object({}) do |(header_name, header_value), h|
      h[header_name] = {
        default: header_value
      }
    end
    swagger_response ||= Fabricate(:swagger_response,                                status: @_transient_attributes[:status],
                                                                                     headers: headers,
                                                                                     schema: @_transient_attributes[:schema])
    @_klass.new swagger_response, {}
  end
  transient status: 200
  transient headers: {
    'Content-Type' => 'application/json'
  }
  transient :schema
end

Fabricator(:swagger_schema, from: Hashie::Mash) do
  transient :version
  initialize_with { @_klass.new to_hash } # Hash based initialization
  type { 'object' }
  required do |attrs|
    attrs[:version] == :draft3 ? true : []
  end
  properties do
    {
      type: 'string'
    }
  end
end

Fabricator(:swagger_an_example, from: Hashie::Mash) do
  initialize_with { @_klass.new to_hash } # Hash based initialization
  transient name: 'default'
  request do |attr|
    {
      body: {
        message: "I am example request #{attr[:name]}"
      }
    }
  end
  response do |attr|
    {
      body: {
        message: "I am example response #{attr[:name]}"
      }
    }
  end
end
