Some generation related [configuration](configuration.rb).

```rb
require 'pacto'
WebMock.allow_net_connect!
Pacto.configure do |c|
  c.contracts_path = 'contracts'
end
WebMock.allow_net_connect!
```

Once we call `Pacto.generate!`, Pacto will record contracts for all requests it detects.

```rb
Pacto.generate!
```

Now, if we run any code that makes an HTTP call (using an
[HTTP library supported by WebMock](https://github.com/bblimke/webmock#supported-http-libraries))
then Pacto will generate a Contract based on the HTTP request/response.

This code snippet will generate a Contract and save it to `contracts/samples/contracts/localhost/api/ping.json`.

```rb
require 'faraday'
conn = Faraday.new(url: 'http://localhost:5000')
response = conn.get '/api/ping'
```

We're getting back real data from GitHub, so this should be the actual file encoding.

```rb
puts response.body
```

The generated contract will contain expectations based on the request/response we observed,
including a best-guess at an appropriate json-schema.  Our heuristics certainly aren't foolproof,
so you might want to customize schema!
Here's another sample that sends a post request.

```rb
conn.post do |req|
  req.url '/api/echo'
  req.headers['Content-Type'] = 'application/json'
  req.body = '{"red fish": "blue fish"}'
end
```

