[![Gem Version](https://badge.fury.io/rb/pacto.png)](http://badge.fury.io/rb/pacto)
[![Build Status](https://travis-ci.org/thoughtworks/pacto.png)](https://travis-ci.org/thoughtworks/pacto)
[![Code Climate](https://codeclimate.com/github/thoughtworks/pacto.png)](https://codeclimate.com/github/thoughtworks/pacto)
[![Dependency Status](https://gemnasium.com/thoughtworks/pacto.png)](https://gemnasium.com/thoughtworks/pacto)
[![Coverage Status](https://coveralls.io/repos/thoughtworks/pacto/badge.png)](https://coveralls.io/r/thoughtworks/pacto)

# Pacto

Pacto is a Ruby framework to help with [Integration Contract Testing](http://martinfowler.com/bliki/IntegrationContractTest.html).

With Pacto you can:

* [Evolve](https://www.relishapp.com/maxlinc/pacto/docs/evolve) your services with either a [Consumer-Driven Contracts](http://martinfowler.com/articles/consumerDrivenContracts.html) approach or by tracking provider contracts.
* [Generate](https://www.relishapp.com/maxlinc/pacto/docs/generate) a contract from your documentation or sample response.
* [Validate](https://www.relishapp.com/maxlinc/pacto/docs/validate) that a live service still matches the Contract you tested against.
* [Stub](https://www.relishapp.com/maxlinc/pacto/docs/stub) services by letting Pacto creates responses that match a Contract.

See the [Usage](#usage) section for some basic examples on how you can use Pacto, and browse the [Relish documentation](https://www.relishapp.com/maxlinc/pacto) for more advanced options.

Pacto's contract validation capabilities are primarily backed by [json-schema](http://json-schema.org/).  This lets you the power of many assertions that will give detailed and precise error messages.  See the specification for possible assertions.

Pacto's stubbing ability ranges from very simple stubbing to:
* Running a server to test from non-Ruby clients
* Generating random or dynamic data as part of the response
* Following simple patterns to simulate resource collections

It's your choice - do you want simple behavior and strict contracts to focus on contract testing, or rich behavior and looser contracts to create dynamic test doubles for collaboration testing?

Note: Currently, Pacto is only designed to work with JSON services.  See the [Constraints](#constraints) section for further information on what Pacto does not do.

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

## Usage

Pacto can be used in a variety of ways.  Here are a few basic options to get you started.

### General Setup

#### Registering Contracts

All of the examples below require Pacto to know what Contracts exist.  You can also associate them with tags so it's easy to active specific groups later.

The easiest way to load a group of contracts is with `Pacto.load_all`, which will load all the Contracts in a directory, bind them to a host, and associate them with a tag.

```ruby
require 'pacto'

Pacto.load_all 'contracts/services', 'http://example.com', :default
Pacto.load_all 'contracts/auth', 'http://example.com', :authentication
Pacto.load_all 'contracts/legacy', 'http://example.com', :legacy
```

#### Rake Tasks

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

### Automatically Stubbing

#### Ruby

In order to use a the registered Contracts as stubs, you just need to call `Pacto.use` with the tag (or tags) you wish to use.

```ruby
Pacto.use :legacy
Pacto.use :authentication, {:username => user, :auth_token => auth_token}
```

Note: the :default group is always included, so you can usually put most of your contracts in :default, and use other tags for Contracts you don't want loaded for most tests.

The values passed in the optional second parameter are used by processors that create the response stubs.  See the documentation for [Configuration](https://www.relishapp.com/maxlinc/pacto/docs/configuration) for available processors.

#### Server

The approach above uses WebMock to stub in-process HTTP requests.  If you want to use the stubs across processes or for non-Ruby clients (even curl) you can easily run Pacto inside a server.

We don't havea  pre-packaged server because its easy to embed Pacto into a simple server so you can customize the configuration and features.  In our our [pacto-demo](https://github.com/thoughtworks/pacto-demo) project we created a [Goliath](https://github.com/postrank-labs/goliath)-based server with 50 lines of Ruby, that could:
- Validate stubs
- Act as a validating reverse proxy

### Validating Providers

You can use Pacto to validate that the providers implementing services match the Contracts used by their consumers.  In addition to the Rake task mentioned above, you can do this programmatically:

```ruby
# You need to allow real HTTP requests!
WebMock.allow_net_connect!
contract = Pacto.build_from_file('/path/to/contract.json', 'http://dummyprovider.com')
contract.validate
```

This will load the contract at `/path/to/contract.json` and make sure a request sent to http://dummyprovider.com complies with the response described in the Contract.


### Validating Custom Stubs

You can use Pacto to validate your existing stubbing system if you aren't ready to let Pacto provide stubs for you.

#### Pure Ruby Stubs

TODO

#### Validating VCR

TODO

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
