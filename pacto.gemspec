# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pacto/version'

plugin_files = Dir['pacto-*.gemspec'].map do |gemspec|
  eval(File.read(gemspec)).files # rubocop:disable Eval
end.flatten.uniq

Gem::Specification.new do |gem|
  gem.name          = 'pacto'
  gem.version       = Pacto::VERSION
  gem.authors       = ['ThoughtWorks & Abril']
  gem.email         = ['pacto-gem@googlegroups.com']
  gem.description   = %q{Pacto is a judge that arbitrates contract disputes between a service provider and one or more consumers. In other words, it is a framework for Integration Contract Testing, and helps guide service evolution patterns like Consumer-Driven Contracts or Documentation-Driven Contracts.}
  gem.summary       = %q{Integration Contract Testing framework}
  gem.homepage      = 'http://thoughtworks.github.io/pacto/'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/) - plugin_files # rubocop:disable SpecialGlobalVars
  gem.executables   = gem.files.grep(/^bin\//).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(/^(test|spec|features)\//)
  gem.require_paths = ['lib']

  gem.add_dependency 'webmock', '~> 1.17'
  gem.add_dependency 'middleware', '~> 0.1'
  gem.add_dependency 'multi_json', '~> 1.8'
  gem.add_dependency 'json-schema', '~> 2.0'
  gem.add_dependency 'json-generator', '~> 0.0', '>= 0.0.5'
  gem.add_dependency 'hash-deep-merge', '~> 0.1'
  gem.add_dependency 'faraday', '~> 0.9'
  gem.add_dependency 'addressable', '~> 2.3'
  gem.add_dependency 'json-schema-generator', '~> 0.0', '>= 0.0.7'
  gem.add_dependency 'term-ansicolor', '~> 1.3'

  gem.add_development_dependency 'coveralls', '~> 0'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rake-notes', '~> 0'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'should_not', '~> 1.0'
  gem.add_development_dependency 'aruba', '~> 0'
  gem.add_development_dependency 'json_spec', '~> 0'
  # Only required to push documentation, and not easily installed on Windows
  # gem.add_development_dependency 'relish'
  gem.add_development_dependency 'guard-rspec', '~> 4.2'
  gem.add_development_dependency 'rubocop', '~> 0.16'
  gem.add_development_dependency 'guard-rubocop', '~> 1.0'
  gem.add_development_dependency 'guard-cucumber', '~> 1.4'
  gem.add_development_dependency 'rb-fsevent', '~> 0' if RUBY_PLATFORM =~ /darwin/i
  gem.add_development_dependency 'terminal-notifier-guard', '~> 1.5' if RUBY_PLATFORM =~ /darwin/i
end
