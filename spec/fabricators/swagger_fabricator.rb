# -*- encoding : utf-8 -*-
require 'pacto'
require 'swagger'

# Fabricators for Swagger API definitions

Fabricator(:swagger_api_operation, from: Swagger::V2::Operation) do
  transient :api
  transient name: 'Dummy Swagger API'
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
  transient schema: {} # Fabricate(:schema, version: 'draft4')

  initialize_with do
    attrs = Hashie::Mash.new(_transient_attributes)
    api_operation_builder = Swagger::Bash.infect(@_klass).new({})
    api_operation_builder.operationId = attrs.name
    api_operation_builder.parameters do | api_parameters |
      attrs.headers.each do | header_name, value |
        api_parameters.push(name: header_name,
                            in: 'header',
                            default: value)
      end if attrs.headers
      attrs.params.each do | param_name, value |
        api_parameters.push(name: param_name,
                            in: 'query',
                            default: value)
      end if attrs.params
      api_parameters.push(name: 'body', in: 'body', schema: attrs.schema) if attrs.schema
    end
    transients = @_transient_attributes
    api = transients.delete :api
    path = transients[:path]
    verb = transients[:http_method].downcase
    api ||= Fabricate(:swagger_api, paths: { path => Swagger::V2::Path.new({}) })
    api.paths[path] ||= Swagger::V2::Path.new({})
    api.paths[path][verb] = api_operation_builder.build
    api_operation = api.paths[path][verb]
    api.attach_to_children
    api_operation
  end

  # after_build do |api_operation, transients|
  #   api = transients.delete :api
  #   path = transients[:path]
  #   verb = transients[:http_method].downcase
  #   api ||= Fabricate(:swagger_api, paths: { path => Swagger::V2::Path.new({}) })
  #   api.paths[path] ||= Swagger::V2::Path.new({})
  #   api.paths[path][verb] = api_operation
  #   api_operation = api.paths[path][verb]
  #   api.attach_to_children
  # end
end

Fabricator(:swagger_response, from: Swagger::V2::Response) do
  transient :api_operation
  transient status: 200

  initialize_with do
    swagger_response_builder = Swagger::Bash.infect(@_klass).new({})
    swagger_response_builder.build
  end

  after_build do |swagger_response, transients|
    api_operation = transients.delete :api_operation
    status = transients[:status]
    api_operation ||= Fabricate(:swagger_api_operation)
    api_operation.responses ||= {}
    api_operation.responses[status.to_s] = swagger_response
    api_operation.attach_to_children
  end
end

Fabricator(:swagger_api, from: Swagger) do
  transient file: 'swagger.yaml'
  transient swagger: '2.0'
  transient host: 'example.com'
  transient :paths

  initialize_with do
    attrs = Hashie::Mash.new(_transient_attributes)
    builder = Swagger::Builder.builder
    builder.swagger = attrs.swagger
    builder.info do | info |
      info.version = 'Required but unused...'
    end
    if attrs.paths
      builder.paths = attrs.paths
    else
      builder.paths = {
        '/' => {}
      }
    end
    Swagger.build_api(builder.build.to_hash)
  end

  after_build do |swagger_api, _transients|
    swagger_api.attach_to_children
  end
end
