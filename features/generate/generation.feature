@needs_server
Feature: Contract Generation

  We know - json-schema can get pretty verbose!  It's a powerful tool, but writing the entire Contract by hand for a complex service is a painstaking task.  We've created a simple generator to speed this process up.  You can invoke it programmatically, or with the provided rake task.

  You just need to create a partial Contract that only describes the request.  The generator will then execute the request, and use the response to generate a full Contract.

  Remember, we only record request headers if they are in the response's [Vary header](http://www.subbu.org/blog/2007/12/vary-header-for-restful-applications), so make sure your services return a proper Vary for best results!

  Background:
    Given a file named "requests/my_contract.json" with:
    """
        {
        "request": {
          "http_method": "GET",
          "path": "/hello",
          "headers": {
            "Accept": "application/json"
          }
        },
        "response": {
          "status": 200,
          "schema": {
            "required": true
          }
        }
      }
    """

  Scenario: Generating a contract using the rake task
    Given a directory named "contracts"
    When I successfully run `bundle exec rake pacto:generate['tmp/aruba/requests','tmp/aruba/contracts','http://localhost:8000']`
    Then the stdout should contain "Successfully generated all contracts"

  Scenario: Generating a contract programmatically
    Given a file named "generate.rb" with:
    """ruby
    require 'pacto'

    WebMock.allow_net_connect!
    generator = Pacto::Generator.new
    contract = generator.generate_from_partial_contract('requests/my_contract.json', 'http://localhost:8000')
    puts contract
    """
    When I successfully run `bundle exec ruby generate.rb`
    Then the stdout should match this contract:
    """json
    {
      "name": "/hello",
      "request": {
        "headers": {
          "Accept": "application/json"
        },
        "http_method": "get",
        "path": "/hello"
      },
      "response": {
        "headers": {
          "Content-Type": "application/json",
          "Vary": "Accept"
        },
        "status": 200,
        "schema": {
          "$schema": "http://json-schema.org/draft-03/schema#",
          "description": "Generated from requests/my_contract.json with shasum 210fa3b144ef2db8d1c160c4d9e8d8bf738ed851",
          "type": "object",
          "required": true,
          "properties": {
            "message": {
              "type": "string",
              "required": true
            }
          }
        }
      }
    }

    """
