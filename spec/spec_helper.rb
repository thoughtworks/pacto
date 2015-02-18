# -*- encoding : utf-8 -*-
require 'coveralls_helper'
require 'webmock/rspec'
require 'pacto'
require 'pacto/test_helper'
require 'fabrication'
require 'stringio'
require 'rspec'

# Pre-load shared examples
require_relative 'unit/pacto/actor_spec.rb'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.include Pacto::TestHelper
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.after(:each) do
    Pacto.clear!
  end
end

def default_pacto_format
  ENV['PACTO_DEFAULT_FORMAT'] || 'legacy'
end

def contracts_folder(format = default_pacto_format)
  "spec/fixtures/contracts/#{format}"
end

def contract_file(name, format = default_pacto_format)
  file = Dir.glob("#{contracts_folder(format)}/#{name}.*").first
  fail "Could not find a #{format} contract for #{name}" if file.nil?
  file
end

def sample_contract
  # Memoized for test speed
  @sample_contract ||= Fabricate(:contract)
end
