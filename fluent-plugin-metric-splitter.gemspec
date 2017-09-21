# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Stephen Gran"]
  gem.email         = ["stephen.gran@piksel.com"]
  gem.description   = %q{Fluentd plugin for to split metric messages into individual metrics}
  gem.summary       = %q{Fluentd plugin for to split metric messages into individual metrics}
  gem.homepage      = "https://github.com/fluent/fluent-plugin-kafka-mesos"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fluent-plugin-metric-splitter"
  gem.require_paths = ["lib"]
  gem.version       = '0.0.2'
  gem.required_ruby_version = ">= 2.1.0"

  gem.add_dependency "fluentd", "0.10.61"
  gem.add_runtime_dependency 'fluent-mixin-rewrite-tag-name'
  gem.add_development_dependency "rake", ">= 0.9.2"
  gem.add_development_dependency "test-unit", ">= 3.0.8"
end
