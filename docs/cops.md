You can create a custom cop that investigates the request/response and sees if it complies with a
contract. The cop should return a list of citations if it finds any problems.

```rb
require 'pacto'
class MyCustomCop
  def investigate(_request, _response, contract)
    citations = []
    citations << 'Contract must have a request schema' if contract.request.schema.empty?
    citations << 'Contract must have a response schema' if contract.response.schema.empty?
    citations
  end
end
```

You can activate the cop by adding it to the active_cops. The active_cops are reset
by `Pacto.clear!`

```rb
Pacto::Cops.active_cops << MyCustomCop.new
```

Or you could add it as a registered cop. These cops are not cleared - they form the
default set of Cops used by Pacto:

```rb
Pacto::Cops.register_cop MyCustomCop.new
```

The cops will be used to validate any service requests/responses detected by Pacto,
including when we simulate consumers:

```rb
Pacto.validate!
contracts = Pacto.load_contracts('contracts', 'http://localhost:5000')
contracts.stub_providers
puts contracts.simulate_consumers
```

You could also completely reset the registered cops if you don't want to use
all of Pacto's built-in cops:

```rb
Pacto::Cops.registered_cops.clear
Pacto::Cops.register_cop Pacto::Cops::ResponseBodyCop

contracts = Pacto.load_contracts('contracts', 'http://localhost:5000')
puts contracts.simulate_consumers
```

