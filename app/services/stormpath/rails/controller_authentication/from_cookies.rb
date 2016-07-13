module Stormpath
  module Rails
    class ControllerAuthentication
      class FromCookies
        OAUTH_ERROR_CODE_RANGE = (10_000...10_100)

        attr_reader :cookies

        def initialize(cookies)
          @cookies = cookies
        end

        def authenticate!
          begin
            AccountFromAccessToken.new(access_token_cookie).account
          rescue AccountFromAccessToken::NoAccessToken, Stormpath::Oauth::Error, JWT::DecodeError
            delete_access_token_cookie
            fetch_account_from_refresh_token
          rescue Stormpath::Error => error
            raise unless OAUTH_ERROR_CODE_RANGE.include?(error.code)
            delete_access_token_cookie
            fetch_account_from_refresh_token
          rescue AccountFromAccessToken::AuthenticationWithRefreshTokenAttemptError
            delete_access_token_cookie
            delete_refresh_token_cookie
            raise UnauthenticatedRequest
          end
        end

        private

        def fetch_account_from_refresh_token
          raise(UnauthenticatedRequest) if refresh_token_cookie.blank?
          begin
            result = RefreshTokenAuthentication.new(refresh_token_cookie).save!
            TokenCookieSetter.new(cookies, result).call
            AccountFromAccessToken.new(result.access_token).account
          rescue Stormpath::Error => error
            raise unless OAUTH_ERROR_CODE_RANGE.include?(error.code)
            delete_refresh_token_cookie
            raise UnauthenticatedRequest
          end
        end

        def access_token_cookie
          cookies[ACCESS_TOKEN_COOKIE_NAME]
        end

        def refresh_token_cookie
          cookies[REFRESH_TOKEN_COOKIE_NAME]
        end

        def access_token_cookie=(value)
          cookies[ACCESS_TOKEN_COOKIE_NAME] = value
        end

        def refresh_token_cookie=(value)
          cookies[REFRESH_TOKEN_COOKIE_NAME] = value
        end

        def delete_access_token_cookie
          cookies.delete(ACCESS_TOKEN_COOKIE_NAME)
        end

        def delete_refresh_token_cookie
          cookies.delete(REFRESH_TOKEN_COOKIE_NAME)
        end
      end
    end
  end
end
