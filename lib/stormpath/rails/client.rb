require "stormpath-sdk"

module Stormpath
  module Rails
    class ConfigurationError < StandardError; end

    if ENV['STORMPATH_URL'].nil? && ENV['STORMPATH_APPLICATION_URL'].nil?
      raise ConfigurationError, 'Either STORMPATH_URL or STORMPATH_APPLICATION_URL must be set'
    end

    class Client
      class << self
        attr_accessor :connection, :root_application
      end

      def self.authenticate_account(username, password)
        auth_result = application.authenticate_account(
          Stormpath::Authentication::UsernamePasswordRequest.new(username, password)
        )
        auth_result.account
      end

      def self.send_password_reset_email(email)
        application.send_password_reset_email email
      end

      def self.verify_password_reset_token(token)
        application.verify_password_reset_token token
      end

      def self.verify_account_email(token)
        self.client.accounts.verify_email_token token
      end

      def self.create_account!(attributes)
        self.application.accounts.create attributes
      end

      def self.all_accounts
        self.application.accounts
      end

      def self.find_account(href)
        self.client.accounts.get href
      end

      def self.update_account!(href, attributes)
        account = self.find_account href
        attributes.each { |field, value| account.send("#{field}=", value) }
        account.save
      end

      def self.delete_account!(href)
        self.client.accounts.get(href).delete
      end

      def self.ds
        self.client.data_store
      end

      def self.application
        self.root_application ||= self.client.applications.get ENV["STORMPATH_APPLICATION_URL"]
      end

      def self.client
        unless self.connection
          composite_url = ENV['STORMPATH_URL']

          if composite_url
            self.root_application = Stormpath::Resource::Application.load composite_url
            self.connection = self.root_application.client
          else
            self.connection = Stormpath::Client.new client_options
          end
        end

        self.connection
      end

      def self.client_options
        Hash.new.tap do |o|
          set_if_not_empty(o, "api_key_file_location", ENV["STORMPATH_API_KEY_FILE_LOCATION"])
          set_if_not_empty(o, "api_key_id_property_name", ENV["STORMPATH_API_KEY_ID_PROPERTY_NAME"])
          set_if_not_empty(o, "api_key_secret_property_name", ENV["STORMPATH_API_KEY_SECRET_PROPERTY_NAME"])

          o[:api_key] = {
            id: ENV["STORMPATH_API_KEY_ID"],
            secret: ENV["STORMPATH_API_KEY_SECRET"]
          } unless ENV["STORMPATH_API_KEY_ID"].blank? or ENV["STORMPATH_API_KEY_SECRET"].blank?
        end
      end

      private

      def self.set_if_not_empty(object, property, value)
        object[property.to_sym] = value unless value.blank?
      end
    end
  end
end
