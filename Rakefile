require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'pacto/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

require 'coveralls/rake/task'
Coveralls::RakeTask.new

Cucumber::Rake::Task.new(:journeys) do |t|
  t.cucumber_opts = "features --format pretty"
end

if defined?(RSpec)
  desc "Run unit tests"
  task :unit do
    abort unless system('rspec --option .rspec_unit')
  end

  desc "Run integration tests"
  task :integration do
    abort unless system('rspec --option .rspec_integration')
  end

  task :default => [:unit, :integration, :journeys, 'coveralls:push']
end
