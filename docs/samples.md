# Overview
Welcome to the Pacto usage samples!
This document gives a quick overview of the main features.

You can browse the Table of Contents (upper right corner) to view additional samples.

In addition to this document, here are some highlighted samples:
<ul>
  <li><a href="configuration">Configuration</a>: Shows all available configuration options</li>
  <li><a href="generation">Generation</a>: More details on generation</li>
  <li><a href="rspec">RSpec</a>: More samples for RSpec expectations</li>
</ul>
You can also find other samples using the Table of Content (upper right corner), including sample contracts.
# Getting started
Once you've installed the Pacto gem, you just require it.  If you want, you can also require the Pacto rspec expectations.

```rb
require 'pacto'
require 'pacto/rspec'
```

Pacto will disable live connections, so you will get an error if
your code unexpectedly calls an service that was not stubbed.  If you
want to re-enable connections, run `WebMock.allow_net_connect!`

```rb
WebMock.allow_net_connect!
```

Pacto can be configured via a block.  The `contracts_path` option tells Pacto where it should load or save contracts.  See the [Configuration](configuration.html) for all the available options.

```rb
Pacto.configure do |c|
  c.contracts_path = 'contracts'
end
```

# Generating a Contract
Calling `Pacto.generate!` enables contract generation.
Pacto.generate!
Now, if we run any code that makes an HTTP call (using an
[HTTP library supported by WebMock](https://github.com/bblimke/webmock#supported-http-libraries))
then Pacto will generate a Contract based on the HTTP request/response.

We're using the sample APIs in the sample_apis directory.

```rb
require 'faraday'
conn = Faraday.new(url: 'http://localhost:5000')
response = conn.get '/api/ping'
```

This is the real request, so you should see {"ping":"pong"}

```rb
puts response.body
```

# Testing providers by simulating consumers
The generated contract will contain expectations based on the request/response we observed,
including a best-guess at an appropriate json-schema.  Our heuristics certainly aren't foolproof,
so you might want to modify the output!
We can load the contract and validate it, by sending a new request and making sure
the response matches the JSON schema.  Obviously it will pass since we just recorded it,
but if the service has made a change, or if you alter the contract with new expectations,
then you will see a contract investigation message.

```rb
contracts = Pacto.load_contracts('contracts', 'http://localhost:5000')
contracts.simulate_consumers
```

# Stubbing providers for consumer testing
We can also use Pacto to stub the service based on the contract.

```rb
contracts.stub_providers
```

The stubbed data won't be very realistic, the default behavior is to return the simplest data
that complies with the schema.  That basically means that you'll have "bar" for every string.

```rb
response = conn.get '/api/ping'
```

You're now getting stubbed data.  You should see {"ping":"bar"} unless you recorded with
the `defaults` option enabled, in which case you will still seee {"ping":"pong"}.

```rb
puts response.body
```

# Collaboration tests with RSpec
Pacto comes with rspec matchers

```rb
require 'pacto/rspec'
```

It's probably a good idea to reset Pacto between each rspec scenario

```rb
RSpec.configure do |c|
  c.after(:each)  { Pacto.clear! }
end
```

Load your contracts, and stub them if you'd like.

```rb
Pacto.load_contracts('contracts', 'http://localhost:5000').stub_providers
```

You can turn on investigation mode so Pacto will detect and validate HTTP requests.

```rb
Pacto.validate!

describe 'my_code' do
  it 'calls a service' do
    conn = Faraday.new(url: 'http://localhost:5000')
    response = conn.get '/api/ping'
```

The have_validated matcher makes sure that Pacto received and successfully validated a request

```rb
    expect(Pacto).to have_validated(:get, 'http://localhost:5000/api/ping')
  end
end
```

