# -*- encoding : utf-8 -*-
require_relative '../../spec/coveralls_helper'
require 'aruba'
require 'aruba/cucumber'
require 'json_spec/cucumber'
require 'aruba/jruby' if RUBY_PLATFORM == 'java'
require 'pacto/test_helper'

Pacto.configuration.hide_deprecations = true

Before do
  # Given I successfully run `bundle install` can take a while.
  @aruba_timeout_seconds = RUBY_PLATFORM == 'java' ? 60 : 10
end

class PactoWorld
  include Pacto::TestHelper
end

World do
  PactoWorld.new
end

Around do | _scenario, block |
  WebMock.allow_net_connect!
  with_pacto(port: 8000, live: true, backend_host: 'http://localhost:5000') do
    block.call
  end
end
