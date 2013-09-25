require 'coveralls_helper'
require 'pacto'
require 'pacto/server'
require 'stringio'

RSpec.configure do |config|
  # I'd like this to be before :each, but there is an issue with one test
  config.before(:each) do
    Pacto.clear!
  end
end
