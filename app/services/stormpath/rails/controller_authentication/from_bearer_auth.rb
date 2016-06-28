module Stormpath
  module Rails
    class ControllerAuthentication
      class FromBearerAuth
        attr_reader :authorization_header

        def initialize(authorization_header)
          @authorization_header = authorization_header
        end

        def authenticate!
          begin
            AccountFromAccessToken.new(bearer_access_token).account
          rescue Stormpath::Oauth::Error, JWT::DecodeError
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
