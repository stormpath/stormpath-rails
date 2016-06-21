module Stormpath
  module Rails
    class ControllerAuthenticator < SimpleDelegator
      UnauthenticatedRequest = Class.new(StandardError)
      BEARER_PATTERN = /^Bearer /
      BASIC_PATTERN = /^Basic /
      OAUTH_ERROR_CODE_RANGE = (10_000...10_100)

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

      # def current_account
      #   @current_account ||= begin
      #     if any_auth_cookie_present?
      #       AccountFromAccessToken.new(cookies[configuration.web.access_token_cookie.name]).account
      #     elsif
      #
      #     elsif
      #
      #     end
      #   end
      # end

      private

      def authenticate_from_cookies
        begin
          Stormpath::Rails::AccountFromAccessToken.new(access_token_cookie).account
        rescue Stormpath::Rails::AccountFromAccessToken::NoAccessToken, Stormpath::Oauth::Error
          delete_access_token_cookie
          fetch_account_from_refresh_token
          # use refresh token cookie to get a new account
          # set new access token cookie
          # set new refresh token cookie
          # set current account
        end
      end

      def fetch_account_from_refresh_token
        begin
          result = Stormpath::Rails::RefreshTokenAuthentication.new(
            refresh_token: refresh_token_cookie
          ).save!
        rescue Stormpath::Error => error
          raise unless OAUTH_ERROR_CODE_RANGE.include?(error.code)
          delete_refresh_token_cookie
          raise UnauthenticatedRequest
        end

        self.access_token_cookie = result.access_token
        self.refresh_token_cookie = result.refresh_token
        Stormpath::Rails::AccountFromAccessToken.new(result.access_token).account
      end

      def authenticate_from_bearer
        begin
          Stormpath::Rails::AccountFromAccessToken.new(bearer_access_token).account
        rescue Stormpath::Oauth::Error, JWT::DecodeError
          raise UnauthenticatedRequest
        end
      end

      def authenticate_from_basic
        raise NotImplementedError
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

      def authorization_header
        request.headers['Authorization']
      end

      def bearer_access_token
        authorization_header.gsub(BEARER_PATTERN, '')
      end

      def basic_authorization_header
        authorization_header.gsub(BASIC_PATTERN, '')
      end

      def cookies
        __getobj__.send(:cookies)
      end

      def configuration
        __getobj__.send(:configuration)
      end
    end
  end
end
