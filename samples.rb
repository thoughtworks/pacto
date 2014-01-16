# Just require pacto to add it to your project.
require 'pacto'
# Pacto will disable live connections, so you will get an error if
# your code unexpectedly calls an service that was not stubbed.  If you
# want to re-enable connections, run `WebMock.allow_net_connect!`
WebMock.allow_net_connect!

# We can be configured via a block.
# See the [Configuration documentation](https://www.relishapp.com/maxlinc/pacto/v/0-3-0/docs/configuration)
# for more options.
Pacto.configure do |c|
  c.contracts_path = 'contracts'
end

# Calling `Pacto.generate!` enables [contract generation](https://www.relishapp.com/maxlinc/pacto/v/0-3-0/docs/generate).
Pacto.generate!

# Now, if we run any code that makes an HTTP call (using an
# [HTTP library supported by WebMock](https://github.com/bblimke/webmock#supported-http-libraries))
# then Pacto will generate a Contract based on the HTTP request/response.
# 
# This code snippet will generate a Contract and save it two `contracts/api.github.com/repos/thoughtworks/pacto/readme.json`.
require 'octokit'
readme = Octokit.readme 'thoughtworks/pacto'
# We're getting back real data from GitHub, so this should be the actual file encoding.
puts readme.encoding

# The generated contract will contain expectations based on the request/response we observed,
# including a best-guess at an appropriate json-schema.  Our heuristics certainly aren't foolproof,
# so you might want to modify the output!

# We can load the contract and validate it, by sending a new request and making sure
# the response matches the JSON schema.  Obviously it will pass since we just recorded it,
# but if the service has made a change, or if you alter the contract with new expectations,
# then you will see a contract validation message.
contracts = Pacto.build_contracts('contracts', 'https://api.github.com')
contracts.validate_all

# We can also use Pacto to stub the service based on the contract.
contracts.stub_all
# The stubbed data won't be very realistic, the default behavior is to return the simplest data
# that complies with the schema.  That basically means that you'll have "bar" for every string.
readme = Octokit.readme 'thoughtworks/pacto'
# You're now getting stubbed data.  Unless you generated the schema with the `defaults` option enabled,
# then this will just return "bar" as the encoding.  If you recorded the defaults, then it will return
# the value received when the Contract was generated.
puts readme.type