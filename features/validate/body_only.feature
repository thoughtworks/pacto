Feature: Validation

  You can validate just the body of the contract.  This may be useful if you want to validate a stubbing system that does not stub the fully connection, or if Pacto is currently unable to validate your headers.

  Background:
    Given a file named "Gemfile" with:
    """ruby
    source 'https://rubygems.org'

    gem 'pacto', :path => '../..'
    gem 'excon'
    """
    Given a file named "validate.rb" with:
      """ruby
      require 'pacto'
      require_relative 'my_service'

      contract_list = Pacto.build_contracts('contracts', 'http://example.com')
      contract_list.stub_all

      contract = contract_list.contracts.first
      service = MyService.new
      response = service.hello
      successful = contract.validate response, :body_only => true
      puts "Validated successfully!" if successful
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

  Scenario: Validate the response body only
    # This should be in the Before block, but https://github.com/cucumber/cucumber/issues/52
    Given I successfully run `bundle install --local`
    Given a file named "my_service.rb" with:
    """ruby
    require 'excon'
    class MyService
      def response(params={})
        body    = params[:body] || {}
        status  = params[:status] || 200
        headers = params[:headers] || {}

        response = Excon::Response.new(:body => body, :headers => headers, :status => status)
        if params.has_key?(:expects) && ![*params[:expects]].include?(response.status)
          raise(Excon::Errors.status_error(params, response))
        else response
        end
      end

      def hello
        body = {
          'message' => 'Hi!'
        }
        response({:body => body})
      end
    end
    """
    When I run `bundle exec ruby validate.rb`
    Then the output should contain:
      """
      Validated successfully!
      """
