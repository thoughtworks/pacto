require 'coveralls_helper'
require 'pacto'
require 'pacto/server'
require 'stringio'
require 'should_not/rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
