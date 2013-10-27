require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'pacto/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'coveralls/rake/task'
require 'rubocop/rake_task'

Coveralls::RakeTask.new

Rubocop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['**/*.rb', 'Rakefile', '*.gemspec']
  # abort rake on failure
  task.fail_on_error = true
end

Cucumber::Rake::Task.new(:journeys) do |t|
  t.cucumber_opts = 'features --format progress'
end

RSpec::Core::RakeTask.new(:unit) do |t|
  t.pattern = 'spec/unit/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:integration) do |t|
  t.pattern = 'spec/integration/**/*_spec.rb'
end

task :default => [:unit, :integration, :journeys, :rubocop, 'coveralls:push']
