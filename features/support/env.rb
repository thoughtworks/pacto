# -*- encoding : utf-8 -*-
require_relative '../../spec/coveralls_helper'
require 'aruba'
require 'aruba/cucumber'
require 'json_spec/cucumber'
require 'aruba/jruby' if RUBY_PLATFORM == 'java'
require 'pacto/test_helper'
require_relative '../../spec/pacto/dummy_server'

Pacto.configuration.hide_deprecations = true

Before do
  # Given I successfully run `bundle install` can take a while.
  @aruba_timeout_seconds = RUBY_PLATFORM == 'java' ? 60 : 10
end

class PactoWorld
  include Pacto::TestHelper
  include Pacto::DummyServer::JRubyWorkaroundHelper
end

World do
  PactoWorld.new
end

Around do | _scenario, block |
  # This is a cucumber bug (see cucumber #640)
  world = self || PactoWorld.new
  world.run_pacto do
    Bundler.with_clean_env do
      block.call
    end
  end
end
