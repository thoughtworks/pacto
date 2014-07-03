require 'pacto'
require 'hashie/mash'

# Fabricators for contracts or parts of contracts

Fabricator(:contract, from: Pacto::Contract) do
  initialize_with { @_klass.new to_hash } # Hash based initialization
  transient example_count: 0
  name { 'Dummy Contract' }
  file { 'file:///does/not/exist/dummy_contract.json' }
  request { Fabricate(:request_clause).to_hash }
  response { Fabricate(:response_clause).to_hash }
  examples do |attr|
    example_count = attr[:example_count]
    if example_count
      examples = attr[:example_count].times.each_with_object({}) do |i, h|
        name = i.to_s
        h[name] = Fabricate(:an_example, name: name)
      end
      examples
    else
      nil
    end
  end
end

Fabricator(:partial_contract, from: Pacto::Contract) do
  initialize_with { @_klass.new to_hash } # Hash based initialization
  name { 'Dummy Contract' }
  file { 'file:///does/not/exist/dummy_contract.json' }
  request { Fabricate(:request_clause).to_hash }
end

Fabricator(:request_clause, from: Pacto::RequestClause) do
  initialize_with { @_klass.new to_hash } # Hash based initialization
  host { 'example.com' }
  http_method { 'GET' }
  path { '/abcd' }
  headers do
    {
      'Server' => ['example.com'],
      'Connection' => ['Close'],
      'Content-Length' => [1234],
      'Via' => ['Some Proxy'],
      'User-Agent' => ['rspec']
    }
  end
  params {}
end

Fabricator(:response_clause, from: Pacto::ResponseClause) do
  initialize_with { @_klass.new to_hash } # Hash based initialization
  status { 200 }
  headers do
    {
      'Content-Type' => 'application/json'
    }
  end
  schema { Fabricate(:schema).to_hash }
end

Fabricator(:schema, from: Hashie::Mash) do
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

Fabricator(:an_example, from: Hashie::Mash) do
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
