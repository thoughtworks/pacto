require "bundler/gem_tasks"
require 'rspec/core/rake_task'

if defined?(RSpec)
  desc "Run unit tests"
  task :unit do
    abort unless system('rspec --option .rspec_unit')
  end

  desc "Run integration tests"
  task :integration do
    abort unless system('rspec --option .rspec_integration')
  end

  task :default => [:unit, :integration]
end
