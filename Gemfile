source 'https://rubygems.org'

# Specify your gem's dependencies in stormpath-rails.gemspec
gemspec

gem 'sqlite3', '~> 1.3'

group :development do
  gem 'pry'
  gem 'pry-byebug'
end

group :test do
  gem 'rspec-rails', '~> 3.3.1'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'shoulda'
  gem 'webmock'
  gem 'vcr'
  gem 'ammeter', git: "https://github.com/alexrothenberg/ammeter", branch: "bigtunacan-master"
end