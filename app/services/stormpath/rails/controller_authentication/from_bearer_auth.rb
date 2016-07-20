module Stormpath
  module Rails
    class ControllerAuthentication
      class FromBearerAuth
        attr_reader :authorization_header

        RESCUE_CLASSES = [
          Stormpath::Oauth::Error,
          JWT::DecodeError,
          AccountFromAccessToken::AuthenticationWithRefreshTokenAttemptError,
          AccountFromAccessToken::DifferentIssuerError
        ].freeze

        def initialize(authorization_header)
          @authorization_header = authorization_header
        end

        def authenticate!
          begin
            AccountFromAccessToken.new(bearer_access_token).account
          rescue *RESCUE_CLASSES
            raise UnauthenticatedRequest
          end
        end

        private

        def bearer_access_token
          authorization_header.gsub(BEARER_PATTERN, '')
        end
      end
    end
  end
end
