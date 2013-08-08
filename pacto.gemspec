# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pacto/version'

Gem::Specification.new do |gem|
  gem.name          = "pacto"
  gem.version       = Pacto::VERSION
  gem.authors       = ["ThoughtWorks & Abril"]
  gem.email         = ["abril_vejasp_dev@thoughtworks.com"]
  gem.description   = %q{Pacto is a Ruby implementation of the [Consumer-Driven Contracts](http://martinfowler.com/articles/consumerDrivenContracts.html) pattern for evolving services}
  gem.summary       = %q{Consumer-Driven Contracts implementation}
  gem.homepage      = 'https://github.com/thoughtworks/pacto'
  gem.license       = 'MIT'


  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "webmock"
  gem.add_dependency "json"
  gem.add_dependency "json-schema", "1.0.4"
  gem.add_dependency "json-generator"
  gem.add_dependency "hash-deep-merge"
  gem.add_dependency "httparty"
  gem.add_dependency "addressable"
  gem.add_dependency "coveralls"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "rb-fsevent" if RUBY_PLATFORM =~ /darwin/i
  gem.add_development_dependency "terminal-notifier-guard" if RUBY_PLATFORM =~ /darwin/i
end
