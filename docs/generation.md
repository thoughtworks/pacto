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

You can provide hints to Pacto to help it generate contracts. For example, Pacto doesn't have
a good way to know a good name and correct URI template for the service. That means that Pacto
will not know if two similar requests are for the same service or two different services, and
will be forced to give names based on the URI that are not good display names.
The hint below tells Pacto that requests to http://localhost:5000/album/1/cover and http://localhost:5000/album/2/cover
are both going to the same service, which is known as "Get Album Cover". This hint will cause Pacto to
generate a Contract for "Get Album Cover" and save it to `contracts/get_album_cover.json`, rather than two
contracts that are stored at `contracts/localhost/album/1/cover.json` and `contracts/localhost/album/2/cover.json`.

```rb
Pacto::Generator.configure do |c|
  c.hint 'Get Album Cover', http_method: :get, host: 'http://localhost:5000', path: '/api/album/{id}/cover'
end
conn.get '/api/album/1/cover'
conn.get '/api/album/2/cover'
```

