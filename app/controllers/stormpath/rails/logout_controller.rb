module Stormpath
  module Rails
    class LogoutController < BaseController

      def create
        DeleteAccessToken.call(cookies[access_token_cookie_name])
        DeleteRefreshToken.call(cookies[refresh_token_cookie_name])

        cookies.delete(access_token_cookie_name)
        cookies.delete(refresh_token_cookie_name)

        logout

        respond_to do |format|
          format.json { render nothing: true, status: 200 }
          format.html do
            set_flash_message :notice, 'You have been logged out successfully.'
            redirect_to configuration.web.logout.next_uri
          end
        end
      end

      private

      def access_token_cookie_name
        configuration.web.access_token_cookie.name
      end

      def refresh_token_cookie_name
        configuration.web.refresh_token_cookie.name
      end
    end
  end
end
