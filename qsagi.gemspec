# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qsagi/version'

Gem::Specification.new do |gem|
  gem.name          = "qsagi"
  gem.version       = Qsagi::VERSION
  gem.authors       = ["Braintree"]
  gem.email         = ["code@getbraintree.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "bunny", "~> 0.8.0"
  gem.add_dependency "json", "~> 1.7.0"
end
