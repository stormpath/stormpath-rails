require 'active_support/concern'
require "stormpath-sdk"
include Stormpath::Client
include Stormpath::Resource

module Stormpath
  module Rails
    module Account
      extend ActiveSupport::Concern

      STORMPATH_FIELDS = [ :email, :password, :username, :given_name, :middle_name, :surname ]

      included do
        self.partial_updates = false

        attr_accessor *STORMPATH_FIELDS
        attr_accessible  *STORMPATH_FIELDS

        after_initialize do |user|
          return unless user.stormpath_url
          begin
            account = Client.find_account(user.stormpath_url)
            (STORMPATH_FIELDS - [:password]).each { |field| self.send("#{field}=", account.send("get_#{field}")) }
          rescue => e
            #somehow mark as data not loaded
          end
        end

        before_create do
          begin
            account = Client.create_account!(Hash[*STORMPATH_FIELDS.map { |f| { f => self.send(f) } }.map(&:to_a).flatten])
          rescue ResourceError => error
            self.errors[:base] << error.to_s
            return false
          end
          self.stormpath_url = account.get_href
        end

        before_update do
          begin
            account = Client.update_account!(self.stormpath_url, Hash[*STORMPATH_FIELDS.map { |f| { f => self.send(f) } }.map(&:to_a).flatten])
          rescue ResourceError => error
            self.errors[:base] << error.to_s
            return nil
          end
        end

        after_destroy do
          begin
            account = Client.delete_account!(self.stormpath_url)
          rescue ResourceError => error
            self.errors[:base] << error.to_s
            return false
          end
        end
      end

      module ClassMethods
      end
    end
  end
end