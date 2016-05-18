module Stormpath
  module Rails
    class LogoutController < BaseController

      def create
        cookies.delete(configuration.web.access_token_cookie.name)
        cookies.delete(configuration.web.refresh_token_cookie.name)

        logout

        respond_to do |format|
          format.json { render nothing: true, status: 200 }
          format.html do
            set_flash_message :notice, 'You have been logged out successfully.'
            redirect_to configuration.web.logout.next_uri
          end
        end
      end

    end
  end
end
