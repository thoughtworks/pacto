Feature: Validation journey
  Scenario: Meta-validation of a valid contract
    Given a file named "contracts/my_contract.json" with:
    """
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
    """
    When I successfully run `rake pacto:meta_validate['tmp/aruba/contracts/my_contract.json']`
    Then the output should contain "All contracts successfully meta-validated"


  Scenario: Meta-validation of an invalid contract
    Given a file named "contracts/my_contract.json" with:
    """
    {"request": "yes"}
    """
    When I run `rake pacto:meta_validate['tmp/aruba/contracts/my_contract.json']`
    Then the exit status should be 1
    And the output should contain "did not match the following type"