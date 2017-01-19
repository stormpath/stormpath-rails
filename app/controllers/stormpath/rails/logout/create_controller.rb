module Stormpath
  module Rails
    module Logout
      class CreateController < BaseController
        BEARER_PATTERN = /^Bearer /

        def call
          if stormpath_config.web.id_site.enabled
            TokenAndCookiesCleaner.new(cookies).remove
            return redirect_to(stormpath_id_site_logout_url)
          elsif bearer_authorization_header?
            DeleteAccessToken.call(bearer_access_token)
          else
            TokenAndCookiesCleaner.new(cookies).remove
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

        def respond_with_success
          respond_to do |format|
            format.html do
              flash[:notice] = 'You have been logged out successfully.'
              redirect_to stormpath_config.web.logout.next_uri
            end
            format.json { render nothing: true, status: 200 }
          end
        end

        def stormpath_id_site_logout_url
          Stormpath::Rails::Client.application.create_id_site_url(callback_uri: id_site_result_url,
                                                                  logout: true)
        end
      end
    end
  end
end
