Feature: Strict Matching

  By default, Pacto matches requests to contracts (and stubs) using exact request paths, parameters, and headers.  This strict behavior is useful for Consumer-Driven Contracts.

  You can use less strict matching so the same contract can match multiple similar requests.  This is useful for matching contracts with resource identifiers in the path.  Any placeholder in the path (like :id in /beers/:id) is considered a resource identifier and will match any alphanumeric combination.

  You can change the default behavior to the behavior that allows placeholders and ignores headers or request parameters by setting the strict_matchers configuration option:

  ```ruby
    Pacto.configure do |config|
      config.strict_matchers = false
    end
  ```

  Background:
    Given a file named "contracts/hello_contract.json" with:
      """json
      {
        "request": {
          "method": "GET",
          "path": "/hello/:id",
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
              "message": { "type": "string", "required": true, "default": "Hello, world!" }
            }
          }
        }
      }
      """

    Given a file named "requests.rb" with:
      """ruby
      require 'pacto'

      strict = ARGV[0] == "true"
      puts "Pacto.configuration.strict_matchers = #{strict}"
      puts

      Pacto.configure do |config|
        config.strict_matchers = strict
      end
      Pacto.load_contracts('contracts', 'http://dummyprovider.com').stub_all

      def response url, headers
        begin
          response = Faraday.get(url) do |req|
            req.headers = headers[:headers]
          end
          response.body
        rescue WebMock::NetConnectNotAllowedError => e
          e.class
        end
      end

      print 'Exact: '
      puts response 'http://dummyprovider.com/hello/:id', headers: {'Accept' => 'application/json' }

      print 'Wrong headers: '
      puts response 'http://dummyprovider.com/hello/:id', headers: {'Content-Type' => 'application/json' }

      print 'ID placeholder: '
      puts response 'http://dummyprovider.com/hello/123', headers: {'Accept' => 'application/json' }
      """

  Scenario: Default (strict) behavior
    When I run `bundle exec ruby requests.rb true`
    Then the output should contain:
      """
      Pacto.configuration.strict_matchers = true

      Exact: {"message":"Hello, world!"}
      Wrong headers: WebMock::NetConnectNotAllowedError
      ID placeholder: WebMock::NetConnectNotAllowedError

      """

  Scenario: Non-strict matching
    When I run `bundle exec ruby requests.rb false`
    Then the output should contain:
      """
      Pacto.configuration.strict_matchers = false

      Exact: {"message":"Hello, world!"}
      Wrong headers: {"message":"Hello, world!"}
      ID placeholder: {"message":"Hello, world!"}
      """    
