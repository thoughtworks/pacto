# Pacto clerks are responsible for loading contracts. Pacto has built-in support for a native
# contract format, but we've setup a Clerks plugin API so you can more easily load information
# from other formats, like [Swagger](https://github.com/wordnik/swagger-spec),
# [apiblueprint](http://apiblueprint.org/), or [RAML](http://raml.org/).

# Note: This is a preliminary API and may change in the future, including adding support
# for conversion between formats, or generating each format from real HTTP interactions.

# In order to add a loading clerk, you just implement a class that responds to build_from_file
# and returns Contract object or a collection of Contract objects.
require 'yaml'
require 'pacto'

class SimpleYAMLClerk
  def build_from_file(path, _host)
    data = YAML.load(File.read(path))
    data['services'].map do | service_name, service_definition |
      request_clause = Pacto::RequestClause.new service_definition['request']
      response_clause = Pacto::ResponseClause.new service_definition['response']
      Pacto::Contract.new(name: service_name, request: request_clause, response: response_clause)
    end
  end
end

# You can then register the clerk with Pacto:
Pacto.contract_factory.add_factory :simple_yaml, SimpleYAMLClerk.new

# And then you can use it with the normal clerks API, by passing the identifier you used to register
# the clerk:
contracts = Pacto.load_contracts 'simple_service_map.yaml', 'http://example.com', :simple_yaml
contract_names = contracts.map(&:name)
puts "Defined contracts: #{contract_names}"
