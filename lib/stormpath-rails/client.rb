require "stormpath-sdk"
include Stormpath::Client
include Stormpath::Resource

module Stormpath
  module Rails
    class Client
      cattr_accessor :_connection

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
        self._connection ||= ::ClientApplicationBuilder.new.set_application_href(Config[:href]).build
        self._connection.client.data_store
      end
    end
  end
end
