module Stormpath
  module Rails
    class AccountFromAccessToken
      attr_reader :access_token

      NoAccessToken = Class.new(ArgumentError)
      AuthenticationWithRefreshTokenAttemptError = Class.new(ArgumentError)

      def initialize(access_token)
        raise(NoAccessToken) if access_token.nil?
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
        jwt_data = JWT.decode(access_token, ENV['STORMPATH_API_KEY_SECRET'])
        raise AuthenticationWithRefreshTokenAttemptError if jwt_data.second['stt'] != 'access'
        jwt_data.first
      rescue JWT::ExpiredSignature
        raise Stormpath::Oauth::Error.new(:jwt_expired)
      end
    end
  end
end
