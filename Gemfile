source 'https://rubygems.org'
PACTO_HOME = File.expand_path '..', __FILE__

# Specify your gem's dependencies in pacto.gemspec
gemspec :name => 'pacto'

Dir["#{PACTO_HOME}/pacto-*.gemspec"].each do |gemspec|
  plugin = gemspec.scan(/pacto-(.*)\.gemspec/).flatten.first
  gemspec(:name => "pacto-#{plugin}", :path => PACTO_HOME, :development_group => plugin)
end

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
