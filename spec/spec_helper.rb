require 'coveralls_helper'
require 'webmock/rspec'
require 'pacto'
require 'pacto/test_helper'
require 'pacto/dummy_server'
require 'stringio'
require 'rspec'
require 'should_not/rspec'

RSpec.configure do |config|
  config.include Pacto::TestHelper
  config.include Pacto::DummyServer::JRubyWorkaroundHelper
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.after(:each) do
    provider = Pacto.configuration.provider
    unless provider.respond_to? :reset!
      provider.stub(:reset!)
    end
    Pacto.clear!
  end
end

def sample_contract(name = 'simple_contract')
  Pacto::NativeContractFactory.new.build_from_file "spec/integration/data/#{name}.json",
                                                   'http://localhost:8080'
end
