module Stormpath
  module Rails
    class ControllerAuthenticator
      UnauthenticatedRequest = Class.new(StandardError)
      BEARER_PATTERN = /^Bearer /
      BASIC_PATTERN = /^Basic /
      OAUTH_ERROR_CODE_RANGE = (10_000...10_100)

      attr_reader :cookies, :authorization_header

      def initialize(cookies, authorization_header)
        @cookies = cookies
        @authorization_header = authorization_header
      end

      def authenticate!
        if any_auth_cookie_present?
          authenticate_from_cookies
        elsif bearer_authorization_header?
          authenticate_from_bearer
        elsif basic_authorization_header?
          authenticate_from_basic
        else
          raise UnauthenticatedRequest
        end
      end

      private

      def authenticate_from_cookies
        begin
          AccountFromAccessToken.new(access_token_cookie).account
        rescue AccountFromAccessToken::NoAccessToken, Stormpath::Oauth::Error
          delete_access_token_cookie
          fetch_account_from_refresh_token
        rescue AccountFromAccessToken::AuthenticationWithRefreshTokenAttemptError
          delete_access_token_cookie
          delete_refresh_token_cookie
          raise UnauthenticatedRequest
        end
      end

      def fetch_account_from_refresh_token
        raise(UnauthenticatedRequest) if refresh_token_cookie.blank?
        begin
          result = RefreshTokenAuthentication.new(
            refresh_token: refresh_token_cookie
          ).save!
        rescue Stormpath::Error => error
          raise unless OAUTH_ERROR_CODE_RANGE.include?(error.code)
          delete_refresh_token_cookie
          raise UnauthenticatedRequest
        end

        TokenCookieSetter.new(cookies, result).call
        AccountFromAccessToken.new(result.access_token).account
      end

      def authenticate_from_bearer
        begin
          AccountFromAccessToken.new(bearer_access_token).account
        rescue Stormpath::Oauth::Error, JWT::DecodeError
          raise UnauthenticatedRequest
        end
      end

      def authenticate_from_basic
        fetched_api_key = Client.application.api_keys.search(id: api_key_id).first
        raise UnauthenticatedRequest if fetched_api_key.nil?
        raise UnauthenticatedRequest if fetched_api_key.secret != api_key_secret
        fetched_api_key.account
      end

      def api_key_id
        decoded_authorization_header.first
      end

      def api_key_secret
        decoded_authorization_header.last
      end

      def decoded_authorization_header
        @decoded_authorization_header ||= begin
          api_key_and_secret = Base64.decode64(basic_authorization_header).split(':')
          raise UnauthenticatedRequest if api_key_and_secret.count != 2
          api_key_and_secret
        end
      end

      def access_token_cookie
        cookies[configuration.web.access_token_cookie.name]
      end

      def refresh_token_cookie
        cookies[configuration.web.refresh_token_cookie.name]
      end

      def access_token_cookie=(value)
        cookies[configuration.web.access_token_cookie.name] = value
      end

      def refresh_token_cookie=(value)
        cookies[configuration.web.refresh_token_cookie.name] = value
      end

      def delete_access_token_cookie
        cookies.delete(configuration.web.access_token_cookie.name)
      end

      def delete_refresh_token_cookie
        cookies.delete(configuration.web.refresh_token_cookie.name)
      end

      def bearer_authorization_header?
        authorization_header =~ BEARER_PATTERN
      end

      def basic_authorization_header?
        authorization_header =~ BASIC_PATTERN
      end

      def any_auth_cookie_present?
        access_token_cookie || refresh_token_cookie
      end

      def bearer_access_token
        authorization_header.gsub(BEARER_PATTERN, '')
      end

      def basic_authorization_header
        authorization_header.gsub(BASIC_PATTERN, '')
      end

      def configuration
        Stormpath::Rails.config
      end
    end
  end
end
