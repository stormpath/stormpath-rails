module Stormpath
  module Rails
    module Logout
      class CreateController < BaseController
        def call
          delete_tokens
          delete_cookies

          respond_to do |format|
            format.html do
              flash[:notice] = 'You have been logged out successfully.'
              redirect_to configuration.web.logout.next_uri
            end
            format.json { render nothing: true, status: 200 }
          end
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
          configuration.web.access_token_cookie.name
        end

        def refresh_token_cookie_name
          configuration.web.refresh_token_cookie.name
        end
      end
    end
  end
end
