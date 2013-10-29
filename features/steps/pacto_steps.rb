Given(/^Pacto is configured with:$/) do |string|
  steps %Q{
    Given a file named "pacto_config.rb" with:
    """ruby
    #{string}
    """
  }
end

When(/^I request "(.*?)"$/) do |url|
  steps %Q{
    Given a file named "request.rb" with:
    """ruby
    require 'pacto'
    require_relative 'pacto_config'
    require 'httparty'

    resp = HTTParty.get('#{url}', headers: {
      'Accept' => 'application/json'
    })
    puts resp.body
    """
    When I run `bundle exec ruby request.rb`
  }
end
