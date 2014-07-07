[![Gem Version](https://badge.fury.io/rb/pacto.png)](http://badge.fury.io/rb/pacto)
[![Build Status](https://travis-ci.org/thoughtworks/pacto.png)](https://travis-ci.org/thoughtworks/pacto)
[![Code Climate](https://codeclimate.com/github/thoughtworks/pacto.png)](https://codeclimate.com/github/thoughtworks/pacto)
[![Dependency Status](https://gemnasium.com/thoughtworks/pacto.png)](https://gemnasium.com/thoughtworks/pacto)
[![Coverage Status](https://coveralls.io/repos/thoughtworks/pacto/badge.png)](https://coveralls.io/r/thoughtworks/pacto)

**If you're viewing this at https://github.com/thoughtworks/pacto,
you're reading the documentation for the master branch.
[View documentation for the latest release
(0.3.0).](https://github.com/thoughtworks/pacto/tree/v0.3.0)**

# Pacto
## Who is Pacto?

Pacto is a judge that arbitrates contract disputes between a **service provider** and one or more **consumers**.  It is a framework for [Integration Contract Testing](http://martinfowler.com/bliki/IntegrationContractTest.html), and service evolution patterns like [Consumer-Driven Contracts](http://thoughtworks.github.io/pacto/patterns/cdc/) or [Documentation-Driven Contracts](http://thoughtworks.github.io/pacto/patterns/documentation_driven/).

## The litigants

Pacto helps settle disputes between **service providers** and **service consumers** of RESTful JSON services. The **provider** is the one that implements the service, which may be used by multiple **consumers**. This is done by [Integration Contract Testing](http://martinfowler.com/bliki/IntegrationContractTest.html), where the contract stays the same but the provider changes.

## Litigators

Someone needs to accuse the **providers** or **consumers** of wrongdoing! Pacto integrates with a few different test frameworks to give you options:

- Pacto easily integrates with [RSpec](http://rspec.info/), including some [custom matchers](#forensics).
- Pacto provides some [simple rake tasks](rake_tasks/) to run some basic tests from the command line.
- If you're testing non-Ruby projects, you can use the [Pacto Server](server) as a proxy to intercept and validate requests. You can also use it in conjunction with [Polytrix](https://github.com/rackerlabs/polytrix).

## Contracts

Pacto considers two major terms in order decide if there has been a breach of contract: the **request clause** and the **response clause**.

The **request clause** defines what information must be sent by the **consumer** to the **provider** in order to compel them to render a service.  The request clause often describes the required HTTP request headers like `Content-Type`, the required parameters, and the required request body (defined in [json-schema](http://json-schema.org/)) when applicable.  Providers are not held liable for failing to deliver services for invalid requests.

The **response clause** defines what information must be returned by the **provider** to the **consumer** in order to successfully complete the transaction.  This commonly includes HTTP response headers like `Location` as well as the required response body (also defined in [json-schema](http://json-schema.org/)).

See the [Contracts documentation](contracts/) for more details.



## Enforcement

### Cops
**Cops** help Pacto investigate interactions between **consumers** and **providers** and determine if either has violated the contract.

Pacto has a few built-in cops that are on-duty by default. These cops will:
- Ensure the request body matches the contract requirements (if a request body is needed)
- Ensure the response headers match the contract requirements
- Ensure the response HTTP status matches the contract requirements
- Ensure the response body matches the contract requirements

### Forensics

Sometimes it looks like you're following a contract, but digital forensics reveals there's some fraud going on. Pacto provides RSpec matchers to help you catch these patterns that let you do the [collaboration tests](http://programmers.stackexchange.com/questions/135011/removing-the-integration-test-scam-understanding-collaboration-and-contract) that integration contract testing alone would not catch.

See the [forensics documetation](forensics/) for more details.

### Sting operations

**Note: this is a preview of an upcoming feature. It is not currently available.**

Pacto **cops** merely observe the interactions between a **consumer** and **provider** and look for problems. A Pacto **sting operation** will alter the interaction in order to try an find problems.

For example, HTTP header field names are supposed to be case-insensitive [according to RFC 2616 - Hypertext Transfer Protocol -- HTTP/1.1](http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2), but many implementations are tightly coupled to a certain server or implementation and assume header field names have a certain case, like "Content-Type" and not "content-type". Pacto can change the alter the character case of the field names in order to catch consumers or providers that are not following this part of the RFC.

Another possible sting operation is to introduce network lag, dropped connections, simulate HTTP rate limiting errors, or other issues that a robust consumer are expected to handle.

You can also add your own custom cops to extend Pacto's abilities or to ensure services are standards that are specific to your organization. See the [Cops documentation](cops/) for more details.

## Inside the courtroom

### Actors

It's not always practical to test using a **real consumer** and or a **real provider**. Pacto can both **stub providers** and **simulate consumers** so you can test their counterpart in isolation. This makes [Consumer-Driven Contracts](http://thoughtworks.github.io/pacto/patterns/cdc/) easier. You can start testing a consumer against a stubbed provider before the real provider is available, and then hand your contracts and tests over to the team that is going to implement the provider so they can ensure it matches your assumptions.

See the [Actors documentation](actors/) for more details.

### The courtroom reporter

**Note: this is a preview of an upcoming feature. It is not currently available.**

Pacto can keep track of which services have been called. If you're a consumer with contracts for a set of services you consumer, this helps you figure out "HTTP Service Coverage", which is quite different from code coverage, so you can see if there's any services you forgot to test, or contracts you're still registering with Pacto even though you no longer use those services.

If you are a provider that is being used by multiple consumers, you could merge coverage reports from each of them to see which services are being used by each consumer. Once this feature is available, you should be able to create reports that look something like this:

![Courtroom Report](https://cloud.githubusercontent.com/assets/896878/2707078/21b0245e-c49d-11e3-8b4e-fa695aa56c4d.png)

### The Stenographer

The stenographer keeps a short-hand record of everything that happens in the courtroom. These logs can be used for troubleshooting, creating reports, or re-enacting the courtroom activities at a later date (and with different [actors](#actors).

The stenographer's logs are similar to HTTP access logs in this respect, but in a format that's more compact and suited to Pacto. A typical HTTP access log might look like this:

```
#Fields: date time c-ip cs-username s-ip s-port cs-method cs-uri-stem cs-uri-query sc-status cs(User-Agent)
2014-07-01 17:42:15 127.0.0.1 - 127.0.0.1 80 PUT /store/album/123/cover_art - 201 curl/7.30.0
2014-07-01 17:42:18 127.0.0.1 - 127.0.0.1 80 GET /store/album/123/cover_art size=small 200 curl/7.30.0
```

If Pacto has the following services registered:
![routes.png](https://draftin.com:443/images/16800?token=8Z2bmsbxOQ74ogeeWTXBwyvVaJ0YBfNJCfQTHa08L3AnvQXsnIf40htwMVudSIugAmpeJp8MD53mN7FPzfgqG9o)

Then it can match those requests to request and generate a stenographer log that looks like this:
```ruby
request 'Upload Album Art', values: {album_id: '123'}, response: {status: 201} # no contract violations
request 'Download Album Art', values: {album_id: '123', size: 'small'}, response: {status: 200} # no contract violations
```

This log file is designed so Pacto it can be used by Pacto to simulate the requests:
```ruby
Pacto.simulate_consumer :my_client do
  request 'Upload Album Art', values: {album_id: '123'}, response: {status: 201} # no contract violations
  request 'Download Album Art', values: {album_id: '123', size: 'small'}, response: {status: 200} # no contract violations
end
```

Since Pacto has added a layer of abstraction you can experiment with changes to the contracts (including routing) without needing to re-record the interactions with the stenographer. For example Pacto will adjust if you change the route from:
![original_put.png](https://draftin.com:443/images/16801?token=6yI7VugUqaLJAMpMvf4oAlPucfQBnfdrdcGpcCuUFET_FH5E0ZreFIrL1C7U2GwRuNndntc9OTIXLD-B2wbkiyg)
to
![new_put.png](https://draftin.com:443/images/16802?token=IagQX2ggHIaaCfRGhR5q85cK9oNN6OgFX2yc9aT0CTZkGzxUMXB1nR40mwIYRat7dUeWPOmLebNOHWXOKlpe-iU)

### Clerks

Clerks help Pacto with paperwork. Reading and writing legalese is hard. Pacto clerks help create and load contracts. Currently clerks are responsible for:

- Generating contracts from real HTTP requests
- Basic support for loading from custom formats

In the future, we plan for clerks to provide more complete support for:
- Converting from or loading other similar contract formats (e.g. [Swagger](https://github.com/wordnik/swagger-spec), [apiblueprint](http://apiblueprint.org/), or [RAML](http://raml.org/).
- Upgrading contracts from older Pacto versions

See the [contract generation](generation/) and [clerks](clerks/) documentation for more info.

# Implied Terms

- Pacto only arbitrates contracts for JSON services.
- Pacto requires Ruby 1.9.3 or newer, though you can use [Polyglot Testing](http://thoughtworks.github.io/pacto/patterns/polyglot/) techniques to support older Rubies and non-Ruby projects.

# Roadmap

See the [Pacto Roadmap](https://github.com/thoughtworks/pacto/wiki/Pacto-Roadmap)

# Contributing

See [CONTRIBUTING.md](https://github.com/thoughtworks/pacto/blob/master/CONTRIBUTING.md)
