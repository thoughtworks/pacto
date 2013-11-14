# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pacto/version'

Gem::Specification.new do |gem|
  gem.name          = 'pacto'
  gem.version       = Pacto::VERSION
  gem.authors       = ['ThoughtWorks & Abril']
  gem.email         = ['pacto-gem@googlegroups.com']
  gem.description   = %q{Pacto is a Ruby implementation of the [Consumer-Driven Contracts](http://martinfowler.com/articles/consumerDrivenContracts.html) pattern for evolving services}
  gem.summary       = %q{Consumer-Driven Contracts implementation}
  gem.homepage      = 'https://github.com/thoughtworks/pacto'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/) # rubocop:disable SpecialGlobalVars
  gem.executables   = gem.files.grep(/^bin\//).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(/^(test|spec|features)\//)
  gem.require_paths = ['lib']

  gem.add_dependency 'webmock'
  gem.add_dependency 'multi_json'
  gem.add_dependency 'json-schema', '~> 2.0'
  gem.add_dependency 'json-generator', '>= 0.0.5'
  gem.add_dependency 'hash-deep-merge'
  gem.add_dependency 'httparty'
  gem.add_dependency 'addressable'
  gem.add_dependency 'coveralls'
  gem.add_dependency 'json-schema-generator'
  gem.add_dependency 'term-ansicolor'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rake-notes'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'should_not'
  gem.add_development_dependency 'aruba'
  gem.add_development_dependency 'relish'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rubocop', '0.14.1'
  gem.add_development_dependency 'guard-rubocop'
  gem.add_development_dependency 'guard-cucumber'
  gem.add_development_dependency 'rb-fsevent' if RUBY_PLATFORM =~ /darwin/i
  gem.add_development_dependency 'terminal-notifier-guard' if RUBY_PLATFORM =~ /darwin/i
end
