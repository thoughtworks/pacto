# Pacto

Pacto is a Ruby implementation of the [Consumer-Driven Contracts](http://martinfowler.com/articles/consumerDrivenContracts.html)
pattern for evolving services. It's main features are:

- A simple language for specifying a contract.
- An automated way to validate that a producer meets it's consumers requirements.
- An auto-generated stub to be used in the consumer's acceptance tests.

It was developed in a micro-services environment, specifically a RESTful one, so expect it to be opinionated. Although
there is enough functionality implemented to motivate us to open-source this, it is still a work in progress and under active
development. Check the Constraints session for further information on what works and what doesn't.

## Specifying Contracts

A contract specifies a single message exchange between a consumer and a provider. In a RESTful world, this means
an HTTP interaction, which is composed of two main parts: a request and a response.

A request has the following attributes:

- Method: the method of the HTTP request (e.g. GET, POST, PUT, DELETE).
- Path: the relative path (without host) of the provider's endpoint.
- Headers: headers sent in the HTTP request.
- Params: any data or parameters of the HTTP request (e.g. query string for GET, body for POST).

A response has the following attributes:

- Status: the HTTP response status code (e.g. 200, 404, 500).
- Headers: the HTTP response headers.
- Body: a JSON Schema defining the expected structure of the HTTP response body.

Pacto relies on a simple, JSON based language for defining contracts. Below is an example contract for a GET request
to the /hello_world endpoint of a provider:

    {
      "request": {
        "method": "GET",
        "path": "/hello_world",
        "headers": {
          "Accept": "application/json"
        },
        "params": {}
      },

      "response": {
        "status": 200,
        "headers": {
          "Content-Type": "application/json"
        },
        "body": {
          "description": "A simple response",
          "type": "object",
          "properties": {
            "message": {
              "type": "string"
            }
          }
        }
      }
    }

The host address is intentionally left out of the request specification so that we can validate a contract against any provider.
It also reinforces the fact that a contract defines the expectation of a consumer, and not the implementation of any specific provider.

## Validating Contracts

There are two ways to validate a contract against a provider: through a Rake task or programatically.

### Rake Task

Pacto includes a default Rake task. To use it, include it in your Rakefile:

    require 'pacto/rake_task'

Validating a contract against a provider is as simple as running:

    $ rake pacto:validate[host,dir]  # Validates all contracts in a given directory against a given host

It is recommended that you also include [colorize](https://github.com/fazibear/colorize) to get prettier, colorful output.

### Programatically

The easiest way to load a contract from a file and validate it against a host is by using the builder interface:

    require 'pacto'

    WebMock.allow_net_connect!
    contract = Pacto.build_from_file('/path/to/contract.json', 'http://dummyprovider.com')
    contract.validate

## Auto-Generated Stubs

Pacto provides an API to be used in the consumer's acceptance tests. It uses a custom JSON Schema parser and generator
to generate a valid JSON document as the response body, and relies on [WebMock](https://github.com/bblimke/webmock)
to stub any HTTP requests made by your application. Important: the JSON generator is in very early stages and does not work
with the entire JSON Schema specification.

First, register the contracts that are going to be used in the acceptance tests suite:

    require 'pacto'

    contract = Pacto.build_from_file('/path/to/contract.json', 'http://dummyprovider.com')
    Pacto.register('my_contract', contract)

Then, in the setup phase of the test, specify which contracts will be used for that test:

    Pacto.use('my_contract')

If default values are not specified in the contract's response body, a default value will be automatically generated. It is possible
to overwrite those values, however, by passing a second argument:

    Pacto.use('my_contract', :value => 'new value')

The values are merged using [hash-deep-merge](https://github.com/Offirmo/hash-deep-merge).

## Code status

[![Build Status](https://travis-ci.org/thoughtworks/pacto.png)](https://travis-ci.org/thoughtworks/pacto)
[![Code Climate](https://codeclimate.com/github/thoughtworks/pacto.png)](https://codeclimate.com/github/thoughtworks/pacto)
[![Dependency Status](https://gemnasium.com/thoughtworks/pacto.png)](https://gemnasium.com/thoughtworks/pacto)
[![Coverage Status](https://coveralls.io/repos/thoughtworks/pacto/badge.png)](https://coveralls.io/r/thoughtworks/pacto)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
