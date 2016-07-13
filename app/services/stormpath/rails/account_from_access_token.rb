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
        @account ||= resolution_class.new(access_token).account
      end

      private

      def resolution_class
        case Stormpath::Rails.config.web.oauth2.password.validation_strategy.to_sym
        when :local
          LocalAccountResolution
        when :stormpath
          StormpathAccountResolution
        else
          raise ArgumentError, 'Invalid validation strategy'
        end
      end
    end
  end
end
