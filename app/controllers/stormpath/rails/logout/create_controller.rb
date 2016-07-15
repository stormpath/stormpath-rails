module Stormpath
  module Rails
    module Logout
      class CreateController < BaseController
        BEARER_PATTERN = /^Bearer /

        def call
          if bearer_authorization_header?
            DeleteAccessToken.call(bearer_access_token)
          else
            delete_tokens
            delete_cookies
          end
          respond_with_success
        end

        private

        def bearer_access_token
          authorization_header.gsub(BEARER_PATTERN, '')
        end

        def bearer_authorization_header?
          authorization_header =~ BEARER_PATTERN
        end

        def authorization_header
          request.headers['Authorization']
        end

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

        def respond_with_success
          respond_to do |format|
            format.html do
              flash[:notice] = 'You have been logged out successfully.'
              redirect_to configuration.web.logout.next_uri
            end
            format.json { render nothing: true, status: 200 }
          end
        end
      end
    end
  end
end
