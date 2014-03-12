require 'json-schema'
require 'json'

data = JSON.parse(File.read 'result.json')
schema = JSON.parse(File.read 'schema.json')
# data = JSON.parse(File.read 'schema.json')
# schema = JSON.parse(File.read 'draft3.json')

puts JSON::Validator.fully_validate schema, data, :version => :draft3, :validate_schema => true
