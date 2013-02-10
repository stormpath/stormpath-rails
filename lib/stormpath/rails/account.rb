require 'active_support/concern'
require "stormpath-sdk"
include Stormpath::Client
include Stormpath::Resource

module Stormpath
  module Rails
    module Account
      extend ActiveSupport::Concern

      STORMPATH_FIELDS = [ :email, :password, :username, :given_name, :middle_name, :surname, :status ]

      included do
        #AR specific workaround
        self.partial_updates = false if self.respond_to?(:partial_updates)

        #Mongoid specific declaration
        #TODO index?
        field(:stormpath_url, type: String) if self.respond_to?(:field)

        attr_accessor *STORMPATH_FIELDS
        attr_accessible  *STORMPATH_FIELDS

        after_initialize do |user|
          return true unless user.stormpath_url
          begin
            account = Client.find_account(user.stormpath_url)
            (STORMPATH_FIELDS - [:password]).each { |field| self.send("#{field}=", account.send("get_#{field}")) }
          rescue ResourceError => error
            Logger.new(STDERR).warn "Error loading Stormpath account (#{error})"
          end
        end

        before_create do
          begin
            account = Stormpath::Rails::Client.create_account!(Hash[*STORMPATH_FIELDS.map { |f| { f => self.send(f) } }.map(&:to_a).flatten])
          rescue ResourceError => error
            self.errors[:base] << error.to_s
            return false
          end
          self.stormpath_url = account.get_href
        end

        before_update do
          return true unless self.stormpath_url
          begin
            Client.update_account!(self.stormpath_url, Hash[*STORMPATH_FIELDS.map { |f| { f => self.send(f) } }.map(&:to_a).flatten])
          rescue ResourceError => error
            self.errors[:base] << error.to_s
            return false
          end
        end

        after_destroy do
          return true unless self.stormpath_url
          begin
            account = Client.delete_account!(self.stormpath_url)
          rescue ResourceError => error
            Logger.new(STDERR).warn "Error destroying Stormpath account (#{error})"
          end
        end
      end
    end
  end
end