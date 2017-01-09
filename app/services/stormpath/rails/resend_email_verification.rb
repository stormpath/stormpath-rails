module Stormpath
  module Rails
    class ResendEmailVerification
      PROPERTY_VALUE_DOES_NOT_MATCH_A_STORMPATH_RESOURCE_CODE = 2016

      attr_reader :email, :account_store

      def initialize(email, account_store = nil)
        raise(NoEmailError, 'Email parameter not provided.') if email.blank?
        @email = email
        @account_store = account_store
      end

      def call
        begin
          application.verification_emails.create(email_verification_params)
        rescue Stormpath::Error => error
          if error.code == PROPERTY_VALUE_DOES_NOT_MATCH_A_STORMPATH_RESOURCE_CODE
            raise UnexistingEmailError, error.message
          else
            raise
          end
        end
      end

      def email_verification_params
        {}.tap do |body|
          body[:login] = email
          body[:account_store] = { name_key: account_store.name_key } if account_store.present?
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
