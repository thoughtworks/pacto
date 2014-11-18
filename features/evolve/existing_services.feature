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

    Faraday.get 'http://www.example.com/service1'
    Faraday.get 'http://www.example.com/service2'
    """
    Then the following files should exist:
    | contracts/www.example.com/service1.json |
    | contracts/www.example.com/service2.json |

  @no-clobber
  Scenario: Ensuring all contracts are valid
    When I successfully run `bundle exec rake pacto:meta_validate['contracts']`
    Then the stdout should contain exactly:
    """
    Validating contracts/www.example.com/service1.json
    Validating contracts/www.example.com/service2.json
    All contracts successfully meta-validated

    """

  # TODO: find where Webmock is being called with and an empty :with
  # and update it, to not use with so we can upgrade Webmock past 1.20.2
  @no-clobber
  Scenario: Stubbing with the contracts
    Given a file named "test.rb" with:
    """ruby
    require 'pacto'

    Pacto.configure do | c |
      c.contracts_path = 'contracts'
    end

    contracts = Pacto.load_contracts('contracts/www.example.com/', 'http://www.example.com')
    contracts.stub_providers

    puts Faraday.get('http://www.example.com/service1').body
    puts Faraday.get('http://www.example.com/service2').body
    """
    When I successfully run `bundle exec ruby test.rb`
    Then the stdout should contain exactly:
    """
    {"thoughtworks":"pacto"}
    {"service2":["thoughtworks","pacto"]}

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

    Pacto.load_contracts('contracts', 'http://www.example.com').stub_providers
    Pacto.validate!

    Faraday.get 'http://www.example.com/service1'
    Faraday.get 'http://www.example.com/service2'
    """
    Then the stdout should contain exactly:
    """

    """
