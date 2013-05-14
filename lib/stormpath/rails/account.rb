require 'active_support/concern'
require "stormpath-sdk"

module Stormpath
  module Rails
    module Account
      extend ActiveSupport::Concern

      STORMPATH_FIELDS = [ :email, :password, :username, :given_name, :middle_name, :surname, :status ]

      included do
        #AR specific workaround
        self.partial_updates = false if self.respond_to?(:partial_updates)

        #Mongoid specific declaration
        field(:stormpath_url, type: String) if self.respond_to?(:field)
        index({ stormpath_url: 1 }, { unique: true }) if self.respond_to?(:index)

        attr_accessor(*STORMPATH_FIELDS)
        attr_accessible(*STORMPATH_FIELDS)

        def stormpath_account
          if stormpath_url
            @stormpath_account ||= begin
                                     Stormpath::Rails::Client.find_account(stormpath_url)
                                   rescue Stormpath::Error => error
                                     Logger.new(STDERR).warn "Error loading Stormpath account (#{error})"
                                   end
          end
        end

        def stormpath_pre_create_attrs
          @stormpath_pre_create_attrs ||= {}
        end

        (STORMPATH_FIELDS - [:password]).each do |name|
          define_method(name) do
            if stormpath_account.present?
              stormpath_account.send(name)
            else
              stormpath_pre_create_attrs[name]
            end
          end
        end

        STORMPATH_FIELDS.each do |name|
          define_method("#{name}=") do |val|
            if stormpath_account.present?
              stormpath_account.send("#{name}=", val)
            else
              stormpath_pre_create_attrs[name] = val
            end
          end
        end

        before_create do
          begin
            @stormpath_account = Stormpath::Rails::Client.create_account! stormpath_pre_create_attrs
            stormpath_pre_create_attrs.clear
            self.stormpath_url = @stormpath_account.href
          rescue Stormpath::Error => error
            self.errors[:base] << error.to_s
            false
          end
        end

        before_update do
          if self.stormpath_url.present?
            begin
              stormpath_account.save
            rescue Stormpath::Error => error
              self.errors[:base] << error.to_s
              false
            end
          else
            true
          end
        end

        after_destroy do
          if self.stormpath_url.present?
            begin
              stormpath_account.delete
            rescue Stormpath::Error => error
              Logger.new(STDERR).warn "Error destroying Stormpath account (#{error})"
            end
          else
            true
          end
        end
      end
    end
  end
end
