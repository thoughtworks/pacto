require "bundler/gem_tasks"
require 'rspec/core/rake_task'

if defined?(RSpec)
  desc "Run unit tests"
  task :spec do
    abort unless system('rspec --option .rspec')
  end

  desc "Run integration tests"
  task :integration do
    abort unless system('rspec --option .rspec_integration')
  end

  task :default => [:spec, :integration]
end
