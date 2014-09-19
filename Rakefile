require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'coveralls/rake/task'
require 'rubocop/rake_task'
require 'rake/notes/rake_task'
require 'rake/packagetask'
Dir.glob('tasks/*.rake').each { |r| import r }
Coveralls::RakeTask.new

require 'pacto/rake_task' # FIXME: This require turns on WebMock
WebMock.allow_net_connect!

RuboCop::RakeTask.new(:rubocop) do |task|
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

task default: [:unit, :integration, :journeys, :samples, :rubocop, 'coveralls:push']

%w(unit integration journeys samples).each do |taskname|
  task taskname => 'smoke_test_services'
end

desc 'Run the samples'
task :samples do
  FileUtils.rm_rf('samples/tmp')
  sh 'bundle exec polytrix exec --solo=samples --solo-glob="*.{rb,sh}"'
  sh 'bundle exec polytrix code2doc --solo=samples --solo-glob="*.{rb,sh}"'
end

desc 'Build the documentation from the samples'
task :documentation do
  sh "docco -t #{Dir.pwd}/docco_embeddable_layout/docco.jst samples/*"
end

desc 'Build gems into the pkg directory'
task :build do
  FileUtils.rm_rf('pkg')
  Dir['*.gemspec'].each do |gemspec|
    system "gem build #{gemspec}"
  end
  FileUtils.mkdir_p('pkg')
  FileUtils.mv(Dir['*.gem'], 'pkg')
end

Rake::PackageTask.new('pacto_docs', Pacto::VERSION) do |p|
  p.need_zip = true
  p.need_tar = true
  p.package_files.include('docs/**/*')
end

def changelog
  changelog = File.read('CHANGELOG').split("\n\n\n", 2).first
  confirm 'Does the CHANGELOG look correct? ', changelog
end

def confirm(question, data)
  puts 'Please confirm...'
  puts data
  print question
  abort 'Aborted' unless $stdin.gets.strip == 'y'
  puts 'Confirmed'
  data
end

desc 'Make sure the sample services are running'
task :smoke_test_services do
  require 'faraday'
  begin
    retryable(tries: 5, sleep: 1) do
      Faraday.get('http://localhost:5000/api/ping')
    end
  rescue
    abort 'Could not connect to the demo services, please start them with `foreman start`'
  end
end

# Retries a given block a specified number of times in the
# event the specified exception is raised. If the retries
# run out, the final exception is raised.
#
# This code is slightly adapted from https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/util/retryable.rb,
# which is in turn adapted slightly from the following blog post:
# http://blog.codefront.net/2008/01/14/retrying-code-blocks-in-ruby-on-exceptions-whatever/
def retryable(opts = nil)
  opts   = { tries: 1, on: Exception }.merge(opts || {})

  begin
    return yield
  rescue *opts[:on] => e
    if (opts[:tries] -= 1) > 0
      $stderr.puts("Retryable exception raised: #{e.inspect}")

      sleep opts[:sleep].to_f if opts[:sleep]
      retry
    end
    raise
  end
end
