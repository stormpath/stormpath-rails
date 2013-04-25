require "stormpath-sdk"
include Stormpath::Authentication

module Stormpath
  module Rails
    class Client
      class << self
        attr_accessor :connection
      end

      def self.authenticate_account(username, password)
        application = self.ds.get_resource ENV["STORMPATH_APPLICATION_URL"], Stormpath::Application
        auth_result = application.authenticate_account ::UsernamePasswordRequest.new(username, password)
        auth_result.account
      end

      def self.send_password_reset_email(username_or_email)
        application = self.ds.get_resource ENV["STORMPATH_APPLICATION_URL"], Stormpath::Application
        application.send_password_reset_email username_or_email
      end

      def self.verify_password_reset_token(token)
        application = self.ds.get_resource ENV["STORMPATH_APPLICATION_URL"], Stormpath::Application
        application.verify_password_reset_token token
      end

      def self.verify_account_email(token)
        self.client.current_tenant.verify_account_email token
      end

      def self.create_account!(attributes)
        account = self.ds.instantiate Stormpath::Account
        attributes.each { |field, value| account.send("#{field}=", value) }
        self.root_directory.create_account account
      end

      def self.all_accounts
        self.root_directory.accounts
      end

      def self.find_account(href)
        self.ds.get_resource href, Stormpath::Account
      end

      def self.update_account!(href, attributes)
        account = self.ds.get_resource href, Stormpath::Account
        attributes.each { |field, value| account.send("#{field}=", value) }
        account.save
      end

      def self.delete_account!(href)
        self.ds.delete self.ds.get_resource href, Stormpath::Account
      end

      def self.root_directory
        self.ds.get_resource ENV["STORMPATH_DIRECTORY_URL"], Stormpath::Directory
      end

      def self.ds
        self.client.data_store
      end

      def self.client
        options = Hash.new.tap do |o|
          set_if_not_empty(o, "application_url", ENV["STORMPATH_APPLICATION_URL"])
          set_if_not_empty(o, "api_key_file_location", ENV["STORMPATH_API_KEY_FILE_LOCATION"])
          set_if_not_empty(o, "api_key_id_property_name", ENV["STORMPATH_API_KEY_ID_PROPERTY_NAME"])
          set_if_not_empty(o, "api_key_secret_property_name", ENV["STORMPATH_API_KEY_SECRET_PROPERTY_NAME"])

          o[:api_key] = {
            id: ENV["STORMPATH_API_KEY_ID"],
            secret: ENV["STORMPATH_API_KEY_SECRET"]
          } unless ENV["STORMPATH_API_KEY_ID"].blank? or ENV["STORMPATH_API_KEY_SECRET"].blank?
        end

        self.connection ||= Stormpath::Client.new options
      end

      private

      def self.set_if_not_empty(object, property, value)
        object[property] = value unless value.blank?
      end
    end
  end
end
