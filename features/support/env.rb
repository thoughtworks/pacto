require_relative '../../spec/coveralls_helper'
require 'aruba'
require 'aruba/cucumber'
require 'json_spec/cucumber'
require 'aruba/jruby' if RUBY_PLATFORM == 'java'
require 'pacto/test_helper'

Before do
  # Given I successfully run `bundle install` can take a while.
  @aruba_timeout_seconds = RUBY_PLATFORM == 'java' ? 60 : 10
end
