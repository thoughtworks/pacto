# Pacto will disable live connections, so you will get an error if
# your code unexpectedly calls an service that was not stubbed.  If you
# want to re-enable connections, run `WebMock.allow_net_connect!` after
# requiring pacto.
require 'pacto'
WebMock.allow_net_connect!

# Pacto can be configured via a block:
Pacto.configure do |c|
  c.contracts_path = 'contracts' # Path for loading/storing contracts.
  c.strict_matchers = true # If the request matching should be strict (especially regarding HTTP Headers).
  c.stenographer_log_file = nil # Set to nil to disable the stenographer log.
end

# You can also do inline configuration.  This example tells the
# [json-schema-generator](https://github.com/maxlinc/json-schema-generator) to
# store default values in the schema.
Pacto.configuration.generator_options = { defaults: true }

# All Pacto configuration and metrics can be reset ia `Pacto.clear!`. If you're using
# RSpec you may want to clear between each scenario:
# If you're using Pacto's rspec matchers you might want to configure a reset between each scenario
require 'pacto/rspec'
RSpec.configure do |c|
  c.after(:each)  { Pacto.clear! }
end
