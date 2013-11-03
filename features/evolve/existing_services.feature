Feature: Existing services journey

  Scenario: Generating the contracts
    Given I have a Rakefile
    Given an existing set of services
    When I execute:
    """ruby
    require 'pacto'

    Pacto.configure do | c |
      c.contracts_path = 'contracts'
    end

    Pacto.generate!

    HTTParty.get 'http://www.example.com/service1'
    HTTParty.get 'http://www.example.com/service2'
    """
    Then the following files should exist:
    | contracts/www.example.com/service1.json |
    | contracts/www.example.com/service2.json |

  @no-clobber
  Scenario: Ensuring all contracts are valid
    When I successfully run `bundle exec rake pacto:meta_validate['contracts']`
    Then the output should contain exactly:
    """
    Validating contracts/www.example.com/service1.json
    Validating contracts/www.example.com/service2.json
    All contracts successfully meta-validated

    """

  @no-clobber
  Scenario: Stubbing with the contracts
    Given a file named "test.rb" with:
    """ruby
    require 'pacto'

    Pacto.configure do | c |
      c.contracts_path = 'contracts'
    end

    Pacto.load_all '.', 'http://www.example.com'
    Pacto.use :default

    puts HTTParty.get 'http://www.example.com/service1'
    puts HTTParty.get 'http://www.example.com/service2'
    """
    When I successfully run `bundle exec ruby test.rb`
    Then the output should contain exactly:
    """
    {"thoughtworks":"bar"}
    {"service2":["bar"]}

    """

  @no-clobber
  Scenario: Expecting a change
    When I make replacements in "contracts/www.example.com/service1.json":
    | pattern | replacement |
    | string  | integer     |
    When I execute:
    """ruby
    require 'pacto'

    Pacto.stop_generating!

    Pacto.configure do | c |
      c.contracts_path = 'contracts'
    end

    Pacto.load_all '.', 'http://www.example.com'
    Pacto.use :default
    Pacto.validate!

    HTTParty.get 'http://www.example.com/service1'
    HTTParty.get 'http://www.example.com/service2'
    """
    Then the output should contain exactly:
    """
    
    """
