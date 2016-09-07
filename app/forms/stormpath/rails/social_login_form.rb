module Stormpath
  module Rails
    class SocialLoginForm
      attr_accessor :provider, :access_token, :cookies, :account

      def initialize(provider, access_token, cookies)
        @provider = provider
        @access_token = access_token
        @cookies = cookies
        validate_provider_presence
        validate_access_token_presence
      end

      class FormError < ArgumentError
        def status
          400
        end
      end

      def save!
        request = Stormpath::Provider::AccountRequest.new(provider.to_sym, :access_token, access_token)
        @account = Stormpath::Rails::Client.application.get_provider_account(request).account
        AccountLoginWithStormpathToken.new(
          cookies, account,
          Stormpath::Rails::Client.application,
          Stormpath::Rails::Client.client.data_store.api_key
        ).call
      end

      private

      def validate_provider_presence
        return if provider.present?
        raise FormError, "providerId can't be blank"
      end

      def validate_access_token_presence
        return if access_token.present?
        raise FormError, "access_token can't be blank"
      end
    end
  end
end
