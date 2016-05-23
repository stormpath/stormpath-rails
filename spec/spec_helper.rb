$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV["RAILS_ENV"] ||= "test"
require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

require 'webmock/rspec'
require 'vcr'
require 'pry'

require "rails/all"
require 'stormpath/rails'
require "dummy/config/environment"
require "rspec/rails"
require 'stormpath/testing/helpers'

require 'factories'

require "support/generator_spec_helpers"
require "support/config_spec_helpers"
require "json_matchers/rspec"
require "match_json"
require 'capybara/rails'
require 'capybara/rspec'

WebMock.allow_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_request do |request|
    request.uri == Stormpath::Rails.config.application.href
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  config.include Stormpath::Testing::Helpers, type: :controller
  config.include Stormpath::Testing::Helpers, type: :request
  config.include Stormpath::Testing::Helpers, type: :feature
  config.include MatchJson::Matchers
  config.include Capybara::DSL, type: :feature

  RSpec::Matchers.alias_matcher :match_json, :include_json

  config.after(:each, type: :controller) do
    delete_test_account
  end

  config.before(:each, type: :controller) do
    request.headers['HTTP_ACCEPT'] = 'text/html'
  end
end

MatchJson::Matchers::IncludeJson::PATTERNS['date_time_iso8601'] = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z/

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, headers: { 'HTTP_ACCEPT' => 'text/html' })
end
