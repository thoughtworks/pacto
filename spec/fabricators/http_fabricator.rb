require 'pacto'
require 'hashie/mash'

# Fabricators for Pacto objects representing HTTP transactions

Fabricator(:pacto_request, from: Pacto::PactoRequest) do
  initialize_with { @_klass.new @_transient_attributes } # Hash based initialization
  # These transient attributes turn into the URI
  transient host: 'example.com'
  transient path: '/abcd'
  transient params: {}
  method { 'GET' }
  uri do |attr|
    Addressable::URI.heuristic_parse(attr[:host]).tap do |uri|
      uri.path = attr[:path]
      uri.query_values = attr[:params]
    end
  end
  headers do
    {
      'Server' => ['example.com'],
      'Connection' => ['Close'],
      'Content-Length' => [1234],
      'Via' => ['Some Proxy'],
      'User-Agent' => ['rspec']
    }
  end
  body do |attr|
    case attr[:method]
    when :get, :head, :options
      nil
    else
      '{"data": "something"}'
    end
  end
end

Fabricator(:pacto_response, from: Pacto::PactoResponse) do
  initialize_with { @_klass.new to_hash } # Hash based initialization
  status { 200 }
  headers do
    {
      'Content-Type' => 'application/json'
    }
  end
  body { '' }
end
