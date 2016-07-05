TEST_ENV_REQUIRED_VARS = [
  :STORMPATH_API_KEY_ID,
  :STORMPATH_API_KEY_SECRET,
  :STORMPATH_SDK_TEST_DIRECTORY_WITH_VERIFICATION_URL
].freeze

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

require 'webmock/rspec'
require 'vcr'
require 'pry'

require 'rails/all'
require 'stormpath/rails'

WebMock.allow_net_connect! # let the configuration load
require 'dummy/config/environment'
WebMock.disable_net_connect!

require 'rspec/rails'

require 'factories'

require 'support/generator_spec_helpers'
require 'support/config_spec_helpers'
require 'support/stormpath_testing_helpers'
require 'json_matchers/rspec'
require 'match_json'
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
  c.ignore_request do |request|
    URI(request.uri).path.ends_with?('/loginAttempts') && request.method == :post
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  config.include Stormpath::Testing::Helpers, type: :request
  config.include Stormpath::Testing::Helpers, type: :feature
  config.include Stormpath::Testing::Helpers, type: :service
  config.include MatchJson::Matchers
  config.include Capybara::DSL, type: :feature
  config.include ConfigSpecHelpers

  RSpec::Matchers.alias_matcher :match_json, :include_json

  config.before(:all) do
    missing_env_vars = TEST_ENV_REQUIRED_VARS.reject { |var| ENV[var.to_s] }
    if missing_env_vars.any?
      raise "Missing the following ENV vars to run the specs: #{missing_env_vars.join(', ')}"
    end
  end

  config.before(:example, type: :feature) do
    allow(JWT::Verify).to receive(:verify_expiration).and_return(nil)
  end

  config.before(:example, type: :request) do
    allow(JWT::Verify).to receive(:verify_expiration).and_return(nil)
  end
end

MatchJson::Matchers::IncludeJson::PATTERNS['date_time_iso8601'] =
  /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z/

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, headers: { 'HTTP_ACCEPT' => 'text/html' })
end
