module Stormpath
  module Rails
    class AccountFromAccessToken
      attr_reader :access_token

      NoAccessToken = Class.new(ArgumentError)
      AuthenticationWithRefreshTokenAttemptError = Class.new(ArgumentError)
      DifferentIssuerError = Class.new(ArgumentError)

      def initialize(access_token)
        raise(NoAccessToken) if access_token.blank?
        @access_token = access_token
      end

      def account
        @account ||= resolution_instance.verify(access_token).account
      end

      private

      def resolution_instance
        case Stormpath::Rails.config.web.oauth2.password.validation_strategy.to_sym
        when :local
          Stormpath::Oauth::VerifyAccessToken.new(Client.application, local: true)
        when :stormpath
          Stormpath::Oauth::VerifyAccessToken.new(Client.application)
        else
          raise ArgumentError, 'Invalid validation strategy'
        end
      end
    end
  end
end
