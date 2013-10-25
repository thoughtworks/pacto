@needs_server
Feature: Contract Generation
  Scenario: Generating a contract from a partial contract
    Given a directory named "contracts"
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
    When I successfully run `bundle exec rake --trace pacto:generate['tmp/aruba/requests','tmp/aruba/contracts','http://localhost:8000']`
    Then the output should contain "Successfully generated all contracts"
