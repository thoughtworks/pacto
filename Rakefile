require 'rspec/core/rake_task'
require 'pacto/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'coveralls/rake/task'
require 'rubocop/rake_task'
require 'rake/notes/rake_task'

Coveralls::RakeTask.new

Rubocop::RakeTask.new(:rubocop) do |task|
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

desc 'Build gems into the pkg directory'
task :build do
  FileUtils.rm_rf('pkg')
  Dir['*.gemspec'].each do |gemspec|
    system "gem build #{gemspec}"
  end
  FileUtils.mkdir_p('pkg')
  FileUtils.mv(Dir['*.gem'], 'pkg')
end

desc 'Tags version, pushes to remote, and pushes gems'
task :release => :build do
  sh 'git', 'tag', '-m', changelog, "v#{Pacto::VERSION}"
  sh 'git push origin master'
  sh "git push origin v#{Pacto::VERSION}"
  sh 'ls pkg/*.gem | xargs -n 1 gem push'
end

task :changelog do
  changelog
end

def changelog
  changelog = File.read('CHANGELOG').split("\n\n\n", 2).first
  confirm "Does the CHANGELOG look correct? ", changelog
end

def confirm(question, data)
  puts "Please confirm..."
  puts data
  print question
  abort "Aborted" unless $stdin.gets.strip == 'y'
  puts "Confirmed"
  data
end
