source 'https://rubygems.org'

# Specify your gem's dependencies in pacto.gemspec
gemspec :name => 'pacto'

Dir['pacto-*.gemspec'].each do |gemspec|
  plugin = gemspec.scan(/pacto-(.*)\.gemspec/).flatten.first
  gemspec(:name => "pacto-#{plugin}", :development_group => plugin)
end

# This is only used by Relish tests.  Putting it here let's travis
# pre-install so we can speed up the test with `bundle install --local`,
# avoiding Aruba timeouts.
gem 'excon'
gem 'octokit'
