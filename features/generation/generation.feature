@needs_server
Feature: Contract Generation

  We know - json-schema can get pretty verbose!  It's a powerful tool, but writing the entire Contract by hand for a complex service is a painstaking task.  We've created a simple generator to speed this process up.  You can invoke it programmatically, or with the provided rake task.

  You just need to create a partial Contract that only describes the request.  The generator will then execute the request, and use the response to generate a full Contract.

  Background:
    Given a file named "requests/my_contract.json" with:
    """
        {
        "request": {
          "method": "GET",
          "path": "/hello",
          "headers": {
            "Accept": "application/json"
          },
          "params": {}
        },
        "response": {
          "status": 200,
          "body": {
            "required": true
          }
        }
      }
    """

  Scenario: Generating a contract using the rake task
    Given a directory named "contracts"
    When I successfully run `bundle exec rake pacto:generate['tmp/aruba/requests','tmp/aruba/contracts','http://localhost:8000']`
    Then the output should contain "Successfully generated all contracts"

  Scenario: Generating a contract programmatically
    Given a file named "generate.rb" with:
    """ruby
    require 'pacto'

    WebMock.allow_net_connect!
    generator = Pacto::Generator.new
    contract = generator.generate('requests/my_contract.json', 'http://localhost:8000')
    puts contract
    """
    When I successfully run `bundle exec ruby generate.rb`
    Then the output should contain exactly:
    """json
    {
      "request": {
        "headers": {
          "Accept": "application/json"
        },
        "method": "get",
        "params": {
        },
        "path": "/hello"
      },
      "response": {
        "headers": {
          "content-type": "application/json",
          "server": "WEBrick/1.3.1 (Ruby/1.9.3/2013-06-27)",
          "date": "Thu, 24 Oct 2013 20:50:20 GMT",
          "content-length": "27",
          "connection": "Keep-Alive"
        },
        "status": 200,
        "body": {
          "$schema": "http://json-schema.org/draft-03/schema#",
          "description": "Generated from generator with shasum 210fa3b144ef2db8d1c160c4d9e8d8bf738ed851",
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