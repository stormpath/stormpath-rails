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

WebMock.allow_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  config.include Stormpath::Testing::Helpers, type: :controller

  config.after(:each, type: :controller) do
    delete_test_account
  end
end
