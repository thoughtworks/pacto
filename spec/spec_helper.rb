require 'coveralls_helper'
require 'webmock/rspec'
require 'pacto'
require 'pacto/server'
require 'stringio'
require 'rspec'
require 'should_not/rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.before(:each) do
    provider = Pacto.configuration.provider
    unless provider.respond_to? :reset!
      provider.stub(:reset!)
    end
    Pacto.clear!
  end
end

def sample_contract(name = 'simple_contract')
  Pacto::ContractFactory.new.build_from_file "spec/integration/data/#{name}.json",
                                             'http://localhost:8080'
end
