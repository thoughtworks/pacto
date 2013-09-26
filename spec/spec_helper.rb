require 'coveralls_helper'
require 'pacto'
require 'pacto/server'
require 'stringio'

RSpec.configure do |config|
  # I'd like this to be before :each, but there is an issue with one test
  config.before(:each) do
    provider = Pacto.configuration.provider
    unless provider.respond_to? :reset!
      provider.stub(:reset!)
    end
    Pacto.clear!
  end
end
