Feature: Templating

  If you want to create more dynamic stubs, you can use Pacto templating.  Currently the only supported templating mechanism is to use ERB in the "default" attributes of the json-schema.

  Background:
    Given Pacto is configured with:
      """ruby
      Pacto.configure do |c|
        c.register_hook Pacto::Hooks::ERBHook.new
      end
      Pacto.load_contracts('contracts', 'http://example.com').stub_all
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
              "message": { "type": "string", "required": true,
                "default": "<%= 'Hello, world!'.reverse %>"
              }
            }
          }
        }
      }
      """

  Scenario: ERB Template
    When I request "http://example.com/hello"
    Then the stdout should contain:
      """
      {"message":"!dlrow ,olleH"}
      """
