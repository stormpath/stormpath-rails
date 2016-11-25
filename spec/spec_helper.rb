$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['RAILS_ENV'] ||= 'test'
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
require 'support/stormpath_social_helpers'
require 'json_matchers/rspec'
require 'match_json'
require 'capybara/rails'
require 'capybara/rspec'

WebMock.allow_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  config.include Stormpath::Testing::Helpers
  config.include Rails.application.routes.url_helpers, type: :service
  config.include MatchJson::Matchers
  config.include Capybara::DSL, type: :feature
  config.include ConfigSpecHelpers
  config.include Stormpath::Social::Helpers
  RSpec::Matchers.alias_matcher :match_json, :include_json

  config.before(:each) do
    Timecop.freeze(
      VCR.current_cassette && VCR.current_cassette.originally_recorded_at || Time.zone.now
    )
  end
end

MatchJson::Matchers::IncludeJson::PATTERNS['date_time_iso8601'] =
  /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z/

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, headers: { 'HTTP_ACCEPT' => 'text/html' })
end

Rails.application.routes.default_url_options[:host] = 'localhost:3000'
