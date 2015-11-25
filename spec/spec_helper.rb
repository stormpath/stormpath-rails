$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV["RAILS_ENV"] ||= "test"
require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

require 'webmock'
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

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.around_http_request do |request|
    uri = URI(request.uri)
    name = "#{[uri.host, uri.path, request.method, request.body].join('/')}"
    VCR.use_cassette(name, :match_requests_on => [:method, :uri, :body], &request)
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  config.include Stormpath::Testing::Helpers, type: :controller

  config.before(:suite) do
    Stormpath::Rails::Client.client.account_store_mappings.create(
      application: Stormpath::Rails::Client.application,
      account_store: Stormpath::Rails::Client.client.directories.create(name: 'test-directory'),
      is_default_account_store: true,
      is_default_group_store: true
    )
  end

  config.after(:suite) do
    test_directory = Stormpath::Rails::Client.client.directories.search(name: 'test-directory').first
    test_directory.delete
  end

  config.after(:each, type: :controller) do
    delete_test_account
  end
end
