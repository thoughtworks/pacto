require "bundler/gem_tasks"
require 'rspec/core/rake_task'

task :integration do
  system('bundle exec rspec integration -I integration')
end

if defined?(RSpec)
  RSpec::Core::RakeTask.new('spec')

  task :default => [:spec, :integration]
end
