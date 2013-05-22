# Note: If SimpleCov starts after your application code is already loaded (via require),
# it won't be able to track your files and their coverage! The SimpleCov.start must be
# issued before any of your application code is required!
require 'simplecov'
SimpleCov.start

require "vcr"
require "webmock"
require "pry"
require "pry-debugger"
require 'stormpath-rails'

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

module Stormpath
  module TestResourceHelpers
    def reload_client()
      Stormpath::Rails.send(:remove_const, :Client)
      load 'lib/stormpath/rails/client.rb'
    end

    def obtain_test_account(opts={})
      opts.tap do |o|
        o['surname']    = (!opts['surname'].blank? && opts['surname']) || 'testsurname'
        o['given_name'] = (!opts['given_name'].blank? && opts['given_name']) || 'testgivenname'
        o['username']   = (!opts['username'].blank? && opts['username']) || 'testfoobar'
        o['password']   = (!opts['password'].blank? && opts['password']) || 'Succ3ss!'
        o['email']      = (!opts['email'].blank? && opts['email']) || 'test+foo+bar@example.com'
      end

      begin
        Stormpath::Rails::Client.create_account! opts
      rescue Stormpath::Error => e
        Stormpath::Rails::Client.authenticate_account(opts['username'], opts['password'])
      end
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
  end

  config.before(:each) do
    reload_client
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end
