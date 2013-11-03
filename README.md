[![Gem Version](https://badge.fury.io/rb/pacto.png)](http://badge.fury.io/rb/pacto)
[![Build Status](https://travis-ci.org/thoughtworks/pacto.png)](https://travis-ci.org/thoughtworks/pacto)
[![Code Climate](https://codeclimate.com/github/thoughtworks/pacto.png)](https://codeclimate.com/github/thoughtworks/pacto)
[![Dependency Status](https://gemnasium.com/thoughtworks/pacto.png)](https://gemnasium.com/thoughtworks/pacto)
[![Coverage Status](https://coveralls.io/repos/thoughtworks/pacto/badge.png)](https://coveralls.io/r/thoughtworks/pacto)

# Pacto

Pacto is a Ruby framework to help with [Integration Contract Testing](http://martinfowler.com/bliki/IntegrationContractTest.html).

**If you're viewing this at https://github.com/thoughtworks/pacto,
you're reading the documentation for the master branch.
[View documentation for the latest release
(0.2.5).](https://github.com/thoughtworks/pacto/tree/v0.2.5)**

With Pacto you can:

* [Evolve](https://www.relishapp.com/maxlinc/pacto/docs/evolve) your services with either a [Consumer-Driven Contracts](http://martinfowler.com/articles/consumerDrivenContracts.html) approach or by tracking provider contracts.
* [Generate](https://www.relishapp.com/maxlinc/pacto/docs/generate) a contract from your documentation or sample response.
* [Validate](https://www.relishapp.com/maxlinc/pacto/docs/validate) your live or stubbed services against expectations to ensure they still comply with your Contracts.
* [Stub](https://www.relishapp.com/maxlinc/pacto/docs/stub) services by letting Pacto creates responses that match a Contract.

See the [Usage](#usage) section for some basic examples on how you can use Pacto, and browse the [Relish documentation](https://www.relishapp.com/maxlinc/pacto) for more advanced options.

Pacto's contract validation capabilities are primarily backed by [json-schema](http://json-schema.org/).  This lets you the power of many assertions that will give detailed and precise error messages.  See the specification for possible assertions.

Pacto's stubbing ability ranges from very simple stubbing to:
* Running a server to test from non-Ruby clients
* Generating random or dynamic data as part of the response
* Following simple patterns to simulate resource collections

It's your choice - do you want simple behavior and strict contracts to focus on contract testing, or rich behavior and looser contracts to create dynamic test doubles for collaboration testing?

Note: Currently, Pacto is only designed to work with JSON services.  See the [Constraints](#constraints) section for further information on what Pacto does not do.

## Usage

Pacto can perform three activities: generating, validating, or stubbing services.  You can do each of these activities against either live or stubbed services.

### Configuration

In order to start with Pacto, you just need to require it and optionally customize the default [Configuration](https://www.relishapp.com/maxlinc/pacto/docs/configuration).  For example:

```ruby
require 'pacto'

Pacto.configure do |config|
  config.contracts_path = 'contracts'
end
```

### Generating

The easiest way to get started with Pacto is to run a suite of live tests and tell Pacto to generate the contracts:

```ruby
Pacto.generate!
# run your tests
```

If you're using the same configuration as above, this will produce Contracts in the contracts/ folder.

We know we cannot generate perfect Contracts, especially if we only have one sample request.  So we do our best to give you a good starting point, but you will likely want to customize the contract so the validation is more strict in some places and less strict in others.

### Registering Contracts

The remaining examples below require Pacto to know what Contracts exist.  You can also associate them with tags so it's easy to active specific groups later.

The easiest way to load a group of contracts is with `Pacto.load_all`, which will load all the Contracts in a directory, bind them to a host, and associate them with a tag.

```ruby
require 'pacto'

Pacto.load_all 'contracts/services', 'http://example.com', :default
Pacto.load_all 'contracts/auth', 'http://example.com', :authentication
Pacto.load_all 'contracts/legacy', 'http://example.com', :legacy
```

### Validating

Once you are happy with your contracts, you can rerun the same tests and validate them against your Contact.  This is as simple as:

```ruby
Pacto.load_all 'contracts', 'http://example.com'
Pacto.validate!
# run your tests again
```

This ensures your live services match the Contracts.

You can also validate your test doubles.  If your test doubles are integration with WebMock, then Pacto.validate! will automatically validate them for you.  This includes VCR while hooked into WebMock.

If you are using a test library that isn't hooked into WebMock, you'll have to incept the HTTP transaction yourself and call Pacto for validation.  That code usually looks something like this:

```ruby
def validate_hook(request, response)
  contract = Pacto.contract_for request
  contract.validate! response
end
```

### Stubbing

In order to use a the registered Contracts as stubs, you just need to call `Pacto.use` with the tag (or tags) you wish to use.

```ruby
Pacto.use :legacy
Pacto.use :authentication, {:username => user, :auth_token => auth_token}
```

Note: the :default group is always included, so you can usually put most of your contracts in :default, and use other tags for Contracts you don't want loaded for most tests.

The values passed in the optional second parameter are used by processors that create the response stubs.  See the documentation for [Configuration](https://www.relishapp.com/maxlinc/pacto/docs/configuration) for available processors.

## Pacto Server (non-Ruby usage)

It is really easy to embed Pacto inside a small server.  We haven't bundled a server inside of Pacto, but check out [pacto-demo](https://github.com/thoughtworks/pacto-demo) to see how easily you can expose Pacto via server.

That demo lets you easily run a server in several modes:
```sh
$ bundle exec ruby pacto_server.rb -sv --generate
# Runs a server that will generate Contracts for each request received
$ bundle exec ruby pacto_server.rb -sv --validate
# Runs the server that provides stubs and checks them against Contracts
$ bundle exec ruby pacto_server.rb -sv --validate --host http://example.com
# Runs the server that acts as a proxy to http://example.com, validating each request/response against a Contract
```

## Rake Tasks

Pacto includes a few Rake tasks to help with common tasks.  If you want to use these tasks, just add this top your Rakefile:

```ruby
require 'pacto/rake_task'
```

This should add several new tasks to you project:
```sh
rake pacto:generate[input_dir,output_dir,host]  # Generates contracts from partial contracts
rake pacto:meta_validate[dir]                   # Validates a directory of contract definitions
rake pacto:validate[host,dir]                   # Validates all contracts in a given directory against a given host
```

The pacto:generate task will take partially defined Contracts and generate the missing pieces.  See [Generate](https://www.relishapp.com/maxlinc/pacto/docs/generate) for more details.

The pacto:meta_validate task makes sure that your Contracts are valid.  It only checks the Contracts, not the services that implement them.

The pacto:validate task sends a request to an actual provider and ensures their response complies with the Contract.  See [Validating Providers](#validating-providers) for more details.

## Contracts

Pacto works by associating a service with a Contract.  The Contract is a JSON description of the service that uses json-schema to describe the response body.  You don't need to write your contracts by hand.  In fact, we recommend generating a Contract from your documentation or a service.  See the [Generators](#generators) for options.

A contract is composed of a request that has:

- Method: the method of the HTTP request (e.g. GET, POST, PUT, DELETE);
- Path: the relative path (without host) of the provider's endpoint;
- Headers: headers sent in the HTTP request;
- Params: any data or parameters of the HTTP request (e.g. query string for GET, body for POST).

And a response has that has:

- Status: the HTTP response status code (e.g. 200, 404, 500);
- Headers: the HTTP response headers;
- Body: a JSON Schema defining the expected structure of the HTTP response body.

Below is an example contract for a GET request
to the /hello_world endpoint of a provider:

```json
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
```

## Generators

Pacto comes with a simple generator to help you get started.  See the [Generate](https://www.relishapp.com/maxlinc/pacto/docs/generate) docs for more details.

It should be possible to write additional generators or hook the existing Generator into other tools, like [VCR](https://github.com/vcr/vcr) cassettes, [apiblueprint](http://apiblueprint.org/), or [WADL](https://wadl.java.net/).  If you want some help or ideas, try the [pacto mailing-list](https://groups.google.com/forum/#!forum/pacto-gem).

## Constraints

- Pacto only works with JSON services
- Pacto requires Ruby 1.9.3 or newer (though you can older Rubies or non-Ruby projects with a [Pacto Server](#server]))
- Pacto cannot currently specify multiple acceptable status codes (e.g. 200 or 201)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
