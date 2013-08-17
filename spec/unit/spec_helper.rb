# Enable Coveralls only on the CI environment
if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
end
