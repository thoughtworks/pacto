# # Overview
# Welcome to the Pacto usage samples!
# This document gives a quick overview of the main features.
#
# You can browse the Table of Contents (upper right corner) to view additional samples.
#
# In addition to this document, here are some highlighted samples:
# <ul>
#   <li><a href="configuration.html">Configuration</a>: Shows all available configuration options</li>
#   <li><a href="generation.html">Generation</a>: More details on generation</li>
#   <li><a href="rspec.html">RSpec</a>: More samples for RSpec expectations</li>
# </ul>

# You can also find other samples using the Table of Content (upper right corner), including sample contracts.

# # Getting started
# Once you've installed the Pacto gem, you just require it.  If you want, you can also require the Pacto rspec expectations.
require 'pacto'
require 'pacto/rspec'
# Pacto will disable live connections, so you will get an error if
# your code unexpectedly calls an service that was not stubbed.  If you
# want to re-enable connections, run `WebMock.allow_net_connect!`
WebMock.allow_net_connect!

# Pacto can be configured via a block.  The `contracts_path` option tells Pacto where it should load or save contracts.  See the [Configuration](configuration.html) for all the available options.
Pacto.configure do |c|
  c.contracts_path = 'contracts'
end

# # Generating a Contract

# Calling `Pacto.generate!` enables contract generation.
Pacto.generate!

# Now, if we run any code that makes an HTTP call (using an
# [HTTP library supported by WebMock](https://github.com/bblimke/webmock#supported-http-libraries))
# then Pacto will generate a Contract based on the HTTP request/response.
#
# Here, we're using [Octokit](https://github.com/octokit/octokit.rb) to call the GitHub API.  It will generate a Contract and save it two `contracts/api.github.com/repos/thoughtworks/pacto/readme.json`.
require 'octokit'
readme = Octokit.readme 'thoughtworks/pacto'
# We're getting back real data from GitHub, so this should be the actual file encoding.
puts readme.encoding

# # Testing providers by simulating consumers

# The generated contract will contain expectations based on the request/response we observed,
# including a best-guess at an appropriate json-schema.  Our heuristics certainly aren't foolproof,
# so you might want to modify the output!

# We can load the contract and validate it, by sending a new request and making sure
# the response matches the JSON schema.  Obviously it will pass since we just recorded it,
# but if the service has made a change, or if you alter the contract with new expectations,
# then you will see a contract validation message.
contracts = Pacto.load_contracts('contracts', 'https://api.github.com')
contracts.validate_all

# # Stubbing providers for consumer testing
# We can also use Pacto to stub the service based on the contract.
contracts.stub_all
# The stubbed data won't be very realistic, the default behavior is to return the simplest data
# that complies with the schema.  That basically means that you'll have "bar" for every string.
readme = Octokit.readme 'thoughtworks/pacto'
# You're now getting stubbed data.  Unless you generated the schema with the `defaults` option enabled,
# then this will just return "bar" as the encoding.  If you recorded the defaults, then it will return
# the value received when the Contract was generated.
puts readme.type

# # Collaboration tests with RSpec

# You can turn on validation mode so Pacto will detect and validate HTTP requests.
Pacto.validate!

# Pacto comes with rspec matchers
require 'pacto/rspec'
describe 'my_code' do
  it 'calls a service' do
    Octokit.readme 'thoughtworks/pacto'
    # The have_validated matcher makes sure that Pacto received and successfully validated a request
    expect(Pacto).to have_validated(:get, 'https://api.github.com/repos/thoughtworks/pacto/readme')
  end
end

# It's probably a good idea to reset Pacto between each rspec scenario
RSpec.configure do |c|
  c.after(:each)  { Pacto.clear! }
end

Pacto.load_contracts('contracts', 'https://api.github.com').stub_all
Pacto.validate!

describe 'my_code' do
  it 'calls a service' do
    Octokit.readme 'thoughtworks/pacto'
    # The have_validated matcher makes sure that Pacto received and successfully validated a request
    expect(Pacto).to have_validated(:get, 'https://api.github.com/repos/thoughtworks/pacto/readme')
  end
end
