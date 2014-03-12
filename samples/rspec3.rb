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

# # Collaboration tests with RSpec

# You can turn on validation mode so Pacto will detect and validate HTTP requests.
# Pacto comes with rspec matchers
require 'pacto/rspec'
describe 'pacto' do
  it 'lets me use rspec matchers' do
    # stub_request(:any, '').to_return(:body => "abc")
    Pacto.validate!
    contracts = Pacto.load_contracts('contracts', 'https://api.github.com')
    contracts.stub_all
    validations = contracts.validate_all
    expect(validations).to_not include(
      a_request_with(:any, //, :headers => {'Expect' => '100-continue'}).and a_response_with_a_body
    )
  end
end
