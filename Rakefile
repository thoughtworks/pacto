require 'rspec/core/rake_task'
# require 'pacto/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'coveralls/rake/task'
require 'rubocop/rake_task'
require 'rake/notes/rake_task'
require 'rake/packagetask'
Dir.glob('tasks/*.rake').each { |r| import r }
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

namespace :server do
  task :autostart do
    Dir.chdir('samples') do
      Bundler.with_clean_env do
        system 'bundle install'
        system 'bundle exec rake server:autostart'
      end
    end
  end
end

%w(unit integration journeys samples).each do |taskname|
  task taskname => 'server:autostart'
end

task :default => [:unit, :integration, :journeys, :samples, :rubocop, 'coveralls:push']

desc 'Run the samples'
task :samples do
  Dir.chdir('samples') do
    Bundler.with_clean_env do
      system 'bundle install'
      Dir['**/*.rb'].each do | sample_code_file |
        next if sample_code_file =~ /sample_api/
        sh "bundle exec ruby -rbundler/setup -rrspec/autorun #{sample_code_file}"
      end
      Dir['**/*.sh'].each do | sample_script |
        sh "./#{sample_script}"
      end
    end
  end
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
