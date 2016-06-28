module Stormpath
  module Rails
    class AccountLoginWithStormpathToken
      def self.call(cookie_jar, account, application, api_key)
        new(cookie_jar, account, application, api_key).call
      end

      def initialize(cookie_jar, account, application, api_key)
        @cookie_jar   = cookie_jar
        @account      = account
        @application  = application
        @api_key      = api_key
      end

      def call
        TokenCookieSetter.call(cookie_jar, authentication_result)
      end

      private

      attr_reader :cookie_jar, :account, :application, :api_key

      def authentication_result
        @authentication_result ||= application.authenticate_oauth(stormpath_grant_request)
      end

      def stormpath_grant_request
        Stormpath::Oauth::StormpathGrantRequest.new(account, application, api_key)
      end
    end
  end
end
