module Stormpath
  module Rails
    class Client
      class << self
        attr_accessor :connection
      end

      def self.sign_in(user)
        account = Stormpath::Resource::Account.new account_params(user)
        account = application.accounts.create account
      end

      def self.account_params(user)
        account_params = user.attributes.select do |k, v|
          %W[given_name surname email username password].include?(k) && !v.nil?
        end
      end

      def self.application
        self.client.applications.get Stormpath::Rails.config.application
      end

      def self.client
        self.connection = Stormpath::Client.new(client_options)
      end

      def self.client_options
        Hash.new.tap { |options| options[:api_key_file_location] = Stormpath::Rails.config.api_key_file }
      end
    end
  end
end