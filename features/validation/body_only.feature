Feature: Validation

  You can use Pacto to do Integration Contract Testing - making sure your service and any test double that simulates the service are similar.  If you generate your Contracts from documentation, you can be fairly confident that all three - live services, test doubles, and documentation - are in sync.

  If already have a response and know the contract it should match, then you can easily validate they match:

  Background:
    Given Pacto is configured with:
      """ruby
      Pacto.load_all 'contracts', 'http://example.com', :default
      Pacto.use :default
      """
    Given a file named "contracts/template.json" with:
      """json
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
          "headers": { "Content-Type": "application/json" },
          "body": {
            "type": "object",
            "required": true,
            "properties": {
              "message": { "type": "string", "required": true
              }
            }
          }
        }
      }
      """

  Scenario: ERB Template
    When I request "http://example.com/hello"
    Then the output should contain:
      """
      {"message":"!dlrow ,olleH"}
      """
