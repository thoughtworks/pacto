# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contracts/version'

Gem::Specification.new do |gem|
  gem.name          = "contracts"
  gem.version       = Contracts::VERSION
  gem.authors       = ["ThoughtWorks VejaSP"]
  gem.email         = ["abril_vejasp_dev@thoughtworks.com"]
  gem.description   = %q{Consumer-Driven Contracts}
  gem.summary       = %q{Consumer-Driven Contracts}

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "webmock"
  gem.add_dependency "json"
  gem.add_dependency "hash-deep-merge"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard-rspec"
end
