require "stormpath-sdk"
include Stormpath::Client
include Stormpath::Resource

module Stormpath
  module Rails
    class Client
      cattr_accessor :connection

      def self.authenticate_account(login, password)
        #TODO remove app href from config
        auth_result = self.application.authenticate_account ::UsernamePasswordRequest.new(login, password)
        auth_result.get_account
      end

      def self.create_account!(attributes)
        account = self.ds.instantiate ::Account
        attributes.each { |field, value| account.send("set_#{field}", value) }
        self.root_directory.create_account account
      end

      def self.all_accounts
        self.root_directory.get_accounts
      end

      def self.find_account(href)
        self.ds.get_resource href, ::Account
      end

      def self.update_account!(href, attributes)
        account = self.ds.get_resource href, ::Account
        attributes.each { |field, value| account.send("set_#{field}", value) }
        account.save
      end

      def self.delete_account!(href)
        self.ds.delete self.ds.get_resource href, ::Account
      end

      def self.root_directory
        self.ds.get_resource Config[:root], ::Directory
      end

      def self.ds
        self.connection ||= ::ClientApplicationBuilder.new.set_application_href(Config[:href]).build
        self.connection.client.data_store
      end

      def self.application
        self.connection ||= ::ClientApplicationBuilder.new.set_application_href(Config[:href]).build
        self.connection.application
      end
    end
  end
end
