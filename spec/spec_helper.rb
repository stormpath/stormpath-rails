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
    def reload_client
      Stormpath::Rails.send(:remove_const, :Client)
      load 'lib/stormpath/rails/client.rb'
    end

    def obtain_test_account(opts={})
      defaults = {
        'surname' => 'testsurname',
        'given_name' => 'testgivenname',
        'username' => 'testfoobar',
        'password' => 'Succ3ss!',
        'email' => 'test+foo+bar@example.com'
      }

      begin
        Stormpath::Rails::Client.create_account! defaults.merge!(opts)
      rescue Stormpath::Error => e
        Stormpath::Rails::Client.authenticate_account(opts['username'], opts['password'])
      end
    end
  end

  class TestEnvironmentConfigurator
    def self.verify_setup
      pfx = 'STORMPATH_RAILS_TEST'

      unless (ENV["#{pfx}_API_KEY_SECRET"] and ENV["#{pfx}_API_KEY_ID"]) or ENV["#{pfx}_API_KEY_FILE_LOCATION"]
        raise <<-message
          Must specify either STORMPATH_RAILS_TEST_API_KEY_FILE_LOCATION or
          STORMPATH_RAILS_TEST_API_KEY_SECRET and STORMPATH_RAILS_TEST_API_KEY_ID
          in order to run tests.
        message
      end

      unless ENV["#{pfx}_APPLICATION_URL"]
        raise <<-message
          Must specify STORMPATH_RAILS_TEST_APPLICATION_URL so that tests have
          an Application Resource to run against.
        message
      end
    end

    def self.create_test_env
      k = %w(SECRET ID FILE_LOCATION ID_PROPERTY_NAME SECRET_PROPERTY_NAME)

      k.each do |v|
        ENV["STORMPATH_API_KEY_#{v}"] = ENV["STORMPATH_RAILS_TEST_API_KEY_#{v}"]
      end

      ENV['STORMPATH_APPLICATION_URL'] = ENV['STORMPATH_RAILS_TEST_APPLICATION_URL']
    end

    def self.prepare_test_environment
      verify_setup
      create_test_env
    end
  end
end

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.order = 'random'
  config.include Stormpath::TestResourceHelpers

  config.before(:all) do
    Stormpath::TestEnvironmentConfigurator.prepare_test_environment
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
