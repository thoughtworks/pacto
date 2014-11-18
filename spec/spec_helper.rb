# -*- encoding : utf-8 -*-
require 'coveralls_helper'
require 'webmock/rspec'
require 'pacto'
require 'pacto/test_helper'
require 'pacto/dummy_server'
require 'fabrication'
require 'stringio'
require 'rspec'

# Pre-load shared examples
require_relative 'unit/pacto/actor_spec.rb'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.include Pacto::TestHelper
  config.include Pacto::DummyServer::JRubyWorkaroundHelper
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.after(:each) do
    Pacto.clear!
  end
end

def sample_contract
  # Memoized for test speed
  @sample_contract ||= Fabricate(:contract)
end

# Configs recommended by RSpec
RSpec.configure do |config|
  config.warnings = true
  config.disable_monkey_patching!
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4.
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end
