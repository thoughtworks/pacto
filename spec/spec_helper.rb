require 'coveralls_helper'
require 'pacto'
require 'pacto/server'
require 'stringio'

RSpec.configure do |config|
  config.before(:each) do
    Pacto.clear!
  end
end
