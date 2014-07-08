# Pacto uses actors stub **providers** or simulate **consumers** based on the contract. There
# are two built-in actors. The FromExamples actor will produce requests or responses based on
# the examples in the contract. The JSONGenerator actor will attempt to generate requests or
# responses that match the JSON schema, though it only works for simple schemas. The FromExamples
# actor is the default, but falls back to the JSONGenerator actor if there are no examples available.

# Consider the following contract:
#
# ```json
# {
#   "name": "Ping",
#   "request": {
#     "headers": {
#     },
#     "http_method": "get",
#     "path": "/api/ping"
#   },
#   "response": {
#     "headers": {
#       "Content-Type": "application/json"
#     },
#     "status": 200,
#     "schema": {
#       "$schema": "http://json-schema.org/draft-03/schema#",
#       "type": "object",
#       "required": true,
#       "properties": {
#         "ping": {
#           "type": "string",
#           "required": true
#         }
#       }
#     }
#   },
#   "examples": {
#     "default": {
#       "request": {
#       },
#       "response": {
#         "body": {
#           "ping": "pong - from the example!"
#         }
#       }
#     }
#   }
# }
# ```

# Then Pacto will generate the following response by default (via FromExamples):
#
# ```json
# {"ping":"pong - from the example!"}
# ```
#
# If you didn't have an example, then Pacto generate very basic mock data based on the schema types,
# producing something like:
#
# ```json
# {"ping":"bar"}
# ```
