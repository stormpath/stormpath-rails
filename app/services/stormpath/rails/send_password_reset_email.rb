module Stormpath
  module Rails
    class SendPasswordResetEmail
      PROPERTY_VALUE_DOES_NOT_MATCH_A_STORMPATH_RESOURCE_CODE = 2016

      attr_reader :email, :account_store

      def initialize(email, account_store = nil)
        raise(NoEmailError, 'Email parameter not provided.') if email.blank?
        @email = email
        @account_store = account_store
      end

      def call
        begin
          application.send_password_reset_email(email, account_store: account_store)
        rescue Stormpath::Error => error
          if error.code == PROPERTY_VALUE_DOES_NOT_MATCH_A_STORMPATH_RESOURCE_CODE
            raise UnexistingEmailError, error.message
          else
            raise
          end
        end
      end

      def application
        Stormpath::Rails::Client.application
      end

      NoEmailError = Class.new(ArgumentError)
      UnexistingEmailError = Class.new(ArgumentError)
    end
  end
end
