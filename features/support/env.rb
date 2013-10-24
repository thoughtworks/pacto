require_relative '../../spec/coveralls_helper'
require 'rake'
require 'aruba'
require 'aruba/cucumber'
require 'aruba/in_process'
require 'aruba/jruby' if RUBY_PLATFORM == 'java'
require 'pacto/server'

Before do
  @aruba_timeout_seconds = RUBY_PLATFORM == 'java' ? 60 : 15
end

# Before do #'@needs_server') do
  @server = Pacto::Server::Dummy.new 8000, '/hello', '{"message": "Hello World!"}'
  @server.start
# end

Around do | scenario, block |
  Bundler.with_clean_env do
    block.call
  end
end

# After('@needs_server') do
#   @server.terminate
# end