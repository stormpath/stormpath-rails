require 'active_support/concern'
require "stormpath-sdk"

module Stormpath
  module Rails
    module Account
      extend ActiveSupport::Concern

      STORMPATH_FIELDS = [ :email, :password, :username, :given_name, :middle_name, :surname, :status ]

      module ClassMethods
        def authenticate username, password
          account = Stormpath::Rails::Client.authenticate_account username, password
          self.where(stormpath_url: account.href).first
        end

        def send_password_reset_email email
          account = Stormpath::Rails::Client.send_password_reset_email email
          self.where(stormpath_url: account.href).first
        end

        def verify_password_reset_token token
          account = Stormpath::Rails::Client.verify_password_reset_token token
          self.where(stormpath_url: account.href).first
        end

        def verify_account_email token
          account = Stormpath::Rails::Client.verify_email_token token
          self.where(stormpath_url: account.href).first
        end
      end

      included do
        #AR specific workaround
        self.partial_updates = false if self.respond_to?(:partial_updates)

        #Mongoid specific declaration
        field(:stormpath_url, type: String) if self.respond_to?(:field)
        index({ stormpath_url: 1 }, { unique: true }) if self.respond_to?(:index)

        attr_accessor(*STORMPATH_FIELDS)
        attr_accessible(*STORMPATH_FIELDS)

        before_create :create_account_on_stormpath
        before_update :update_account_on_stormpath
        after_destroy :delete_account_on_stormpath

        def stormpath_account
          if stormpath_url
            @stormpath_account ||= begin
                                     Stormpath::Rails::Client.find_account(stormpath_url)
                                   rescue Stormpath::Error => error
                                     Stormpath::Rails.logger.warn "Error loading Stormpath account (#{error})"
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

        def create_account_on_stormpath
          begin
            @stormpath_account = Stormpath::Rails::Client.create_account! stormpath_pre_create_attrs
            stormpath_pre_create_attrs.clear
            self.stormpath_url = @stormpath_account.href
          rescue Stormpath::Error => error
            self.errors[:base] << error.to_s
            false
          end
        end

        def update_account_on_stormpath
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

        def delete_account_on_stormpath
          if self.stormpath_url.present?
            begin
              stormpath_account.delete
            rescue Stormpath::Error => error
              Stormpath::Rails.logger.warn "Error destroying Stormpath account (#{error})"
            end
          else
            true
          end
        end
      end
    end
  end
end
