# # -*- encoding : utf-8 -*-
# require 'pacto'
# require 'swagger'

# # Fabricators for Swagger API definitions

# Fabricator(:swagger_api, from: Swagger) do
#   transient name: 'Dummy Swagger Contract'
#   transient file: 'swagger.yaml'
#   transient :examples
#   transient swagger: '2.0'
#   transient host: 'example.com'
#   transient http_method: 'GET'
#   transient path: '/abcd'
#   transient headers: {
#     'Server' => ['example.com'],
#     'Connection' => ['Close'],
#     'Content-Length' => [1234],
#     'Via' => ['Some Proxy'],
#     'User-Agent' => ['rspec']
#   }
#   transient params: {}

#   transient status: 200
#   # Note, need to distinguish request vs response headers/schema/etc when calling from Contract fabricator
#   transient response_headers: {
#     'Content-Type' => 'application/json'
#   }
#   transient schema: {} #Fabricate(:schema).to_hash

#   transient :request
#   transient :response

#   initialize_with do
#     attrs = Hashie::Mash.new(_transient_attributes)
#     builder = Swagger::Builder.builder
#     builder.swagger = attrs.swagger
#     builder.info do | info |
#       info.version = 'Required but unused...'
#     end
#     builder.paths = {
#       attrs.path => {}
#     }
#     builder.paths[attrs.path].send(attrs.http_method.downcase) do |api_operation|
#       api_operation.operationId = attrs.name
#       api_operation.parameters do | api_parameters |
#         attrs.headers.each do | header_name, value |
#           api_parameters.push({
#             name: header_name,
#             in: 'header',
#             default: value
#           })
#         end
#         attrs.params.each do | param_name, value |
#           api_parameters.push({
#             name: param_name,
#             in: 'query',
#             default: value
#           })
#         end
#       end
#     end
#     builder.responses = {
#       attrs.status => {}
#     }
#     builder.build
#   end
# end

# Fabricator(:swagger_api_operation, from: :swagger_api) do
#   initialize_with do
#     transients = _transient_attributes
#     path = transients[:path]
#     verb = transients[:http_method].downcase
#     data = to_hash.merge(transients)
#     Fabricate(:swagger_api, data).paths[path].send(verb)
#   end
# end

# Fabricator(:swagger_response, from: :swagger_api_operation) do
#   initialize_with do
#     transients = _transient_attributes
#     status_code = transients[:status]
#     data = to_hash.merge(transients)
#     Fabricate(:swagger_api, data).responses[status_code.to_s]
#   end
# end
