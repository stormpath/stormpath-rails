require "stormpath-sdk"
include Stormpath::Authentication

module Stormpath
  module Rails
    class Client
      class << self
        attr_accessor :connection
      end

      def self.authenticate_account(login, password)
        application = self.ds.get_resource Config[:stormpath_url], Stormpath::Application
        auth_result = application.authenticate_account ::UsernamePasswordRequest.new(login, password)
        auth_result.get_account
      end

      def self.send_password_reset_email(login_or_email)
        application = self.ds.get_resource Config[:stormpath_url], Stormpath::Application
        application.send_password_reset_email login_or_email
      end

      def self.verify_password_reset_token(token)
        application = self.ds.get_resource Config[:stormpath_url], Stormpath::Application
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
        self.root_directory.get_accounts
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
        self.ds.get_resource Config[:root], Stormpath::Directory
      end

      def self.ds
        self.client.data_store
      end

      def self.client
        self.connection ||= Stormpath::Client.new({
          application_href: Config[:stormpath_url] || Config[:href]
        })
        self.connection.client
      end
    end
  end
end
