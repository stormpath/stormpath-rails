# Note: If SimpleCov starts after your application code is already loaded (via require),
# it won't be able to track your files and their coverage! The SimpleCov.start must be
# issued before any of your application code is required!
require 'simplecov'
SimpleCov.start

require "stormpath-rails"

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

module Stormpath
  module TestResourceHelpers
    def generate_resource_name
      "Test#{SecureRandom.uuid}"
    end

    def destroy_all_stormpath_test_accounts
      Stormpath::Rails::Client.all_accounts.each do |account|
        Stormpath::Rails::Client.delete_account! account.href
      end
    end

    def create_test_user(opts={})
      opts.tap do |o|
        o["surname"]    = (!opts["surname"].blank? && opts["surname"]) || generate_resource_name
        o["given_name"] = (!opts["given_name"].blank? && opts["given_name"]) || generate_resource_name
        o["username"]   = (!opts["username"].blank? && opts["username"]) || generate_resource_name
        o["password"]   = (!opts["password"].blank? && opts["password"]) || generate_resource_name
        o["email"]      = (!opts["email"].blank? && opts["email"]) || "#{generate_resource_name}@example.com"
      end

      Stormpath::Rails::Client.create_account! opts
    end
  end
end

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.order = 'random'
  config.include Stormpath::TestResourceHelpers

  config.before(:all) do
    ENV["STORMPATH_API_KEY_SECRET"]               = ENV["STORMPATH_RAILS_TEST_API_KEY_SECRET"]
    ENV["STORMPATH_API_KEY_ID"]                   = ENV["STORMPATH_RAILS_TEST_API_KEY_ID"]
    ENV["STORMPATH_APPLICATION_URL"]              = ENV["STORMPATH_RAILS_TEST_APPLICATION_URL"]
    ENV["STORMPATH_API_KEY_FILE_LOCATION"]        = ENV["STORMPATH_RAILS_TEST_API_KEY_FILE_LOCATION"]
    ENV["STORMPATH_API_KEY_ID_PROPERTY_NAME"]     = ENV["STORMPATH_RAILS_TEST_API_KEY_ID_PROPERTY_NAME"]
    ENV["STORMPATH_API_KEY_SECRET_PROPERTY_NAME"] = ENV["STORMPATH_RAILS_TEST_API_KEY_SECRET_PROPERTY_NAME"]

    destroy_all_stormpath_test_accounts
  end

  config.after(:all) do
    destroy_all_stormpath_test_accounts
  end
end
