# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qsagi/version'

Gem::Specification.new do |gem|
  gem.name          = "qsagi"
  gem.version       = Qsagi::VERSION
  gem.authors       = ["Braintree"]
  gem.email         = ["code@getbraintree.com"]
  gem.description   = "A friendly way to talk to RabbitMQ"
  gem.summary       = "A friendly way to talk to RabbitMQ"
  gem.homepage      = "https://github.com/braintree/qsagi"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "bunny", "~> 1.2.0"
  gem.add_dependency "json", "~> 1.7"
end
