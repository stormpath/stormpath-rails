module Stormpath
  module Rails
    class AccountFromAccessToken
      attr_reader :access_token

      def initialize(access_token)
        @access_token = access_token
      end

      def account
        @account ||= Stormpath::Rails::Client.client.accounts.get(account_href)
      end

      private

      def account_href
        jwt_response['sub']
      end

      def jwt_response
        JWT.decode(access_token, ENV['STORMPATH_API_KEY_SECRET']).first
      rescue JWT::ExpiredSignature
        raise Stormpath::Oauth::Error.new(:jwt_expired)
      end
    end
  end
end
