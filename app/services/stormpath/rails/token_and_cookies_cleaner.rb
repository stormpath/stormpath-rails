module Stormpath
  module Rails
    class TokenAndCookiesCleaner
      attr_reader :cookies

      def initialize(cookies)
        @cookies = cookies
      end

      def remove
        delete_tokens
        delete_cookies
      end

      private

      def delete_tokens
        DeleteAccessToken.call(cookies[access_token_cookie_name])
        DeleteRefreshToken.call(cookies[refresh_token_cookie_name])
      end

      def delete_cookies
        cookies.delete(access_token_cookie_name)
        cookies.delete(refresh_token_cookie_name)
      end

      def access_token_cookie_name
        Stormpath::Rails.config.web.access_token_cookie.name
      end

      def refresh_token_cookie_name
        Stormpath::Rails.config.web.refresh_token_cookie.name
      end
    end
  end
end
