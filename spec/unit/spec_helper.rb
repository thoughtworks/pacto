require 'coveralls_helper'

RSpec.configure do |config|
  config.before(:each) do
    Pacto.clear!
  end
end
