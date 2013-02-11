lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stormpath/rails/version'

Gem::Specification.new do |gem|
  gem.name          = "stormpath-rails"
  gem.version       = Stormpath::Rails::VERSION
  gem.authors       = ["Denis Grankin"]
  gem.email         = ["liquidautumn@gmail.com"]
  gem.homepage      = "http://www.stormpath.com"
  gem.description   = %q{Stormpath Rails integration}
  gem.summary       = %q{Stormpath SDK API Wrapper}

  gem.add_dependency "activesupport"
  gem.add_dependency "stormpath-sdk", '~> 0.4.0'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency('rake', '~> 10.0.2')
  gem.add_development_dependency('rspec', '~> 2.12.0')
  gem.add_development_dependency('activerecord')
  gem.add_development_dependency('sqlite3')
  gem.add_development_dependency('mongoid')
  gem.add_development_dependency('railties')
  gem.add_development_dependency('guard-rspec', '~> 2.2.1')
  gem.add_development_dependency('rb-inotify', '~> 0.8.8')
end
