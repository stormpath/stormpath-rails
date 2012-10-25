# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stormpath/rails/version'

Gem::Specification.new do |gem|
  gem.name          = "stormpath-rails"
  gem.version       = Stormpath::Rails::VERSION
  gem.authors       = ["Denis Grankin"]
  gem.email         = ["liquidautumn@gmail.com"]
  gem.description   = %q{Stormpath Rails integration}
  gem.summary       = %q{Stormpath SDK API Wrapper}

  gem.add_dependency "activesupport"
  gem.add_dependency "stormpath-sdk"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
