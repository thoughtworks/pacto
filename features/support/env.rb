require_relative '../../spec/coveralls_helper'
require "rake"
require "aruba"
require 'aruba/cucumber'
require "aruba/in_process"
require "aruba/jruby" if RUBY_PLATFORM == 'java'

Before do
  @aruba_timeout_seconds = RUBY_PLATFORM == 'java' ? 60 : 10
end
