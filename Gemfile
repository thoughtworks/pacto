source 'https://rubygems.org'

# Specify your gem's dependencies in pacto.gemspec
gemspec name: 'pacto'
gemspec name: 'pacto-server'

# This is only used by Relish tests.  Putting it here let's travis
# pre-install so we can speed up the test with `bundle install --local`,
# avoiding Aruba timeouts.
gem 'excon'
gem 'octokit'

group :samples do
  gem 'grape'
  gem 'grape-swagger'
  gem 'puma'
  gem 'rake'
  gem 'pry'
  gem 'rack'
end
