
```rb
require 'pacto'
Pacto.configure do |c|
  c.contracts_path = 'contracts'
end
Pacto.validate!
```

You can create a custom cop that investigates the request/response and sees if it complies with a
contract. The cop should return a list of citations if it finds any problems.

```rb
class MyCustomCop
  def investigate(_request, _response, contract)
    citations = []
    citations << 'Contract must have a request schema' if contract.request.schema.empty?
    citations << 'Contract must have a response schema' if contract.response.schema.empty?
    citations
  end
end

Pacto::Cops.active_cops << MyCustomCop.new

contracts = Pacto.load_contracts('contracts', 'http://localhost:5000')
contracts.stub_providers
puts contracts.simulate_consumers
```

Or you can completely replace the default set of validators

```rb
Pacto::Cops.registered_cops.clear
Pacto::Cops.register_cop Pacto::Cops::ResponseBodyCop

contracts = Pacto.load_contracts('contracts', 'http://localhost:5000')
puts contracts.simulate_consumers
```

