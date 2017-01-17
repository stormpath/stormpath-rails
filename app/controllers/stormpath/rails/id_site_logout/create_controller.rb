module Stormpath
  module Rails
    module IdSiteLogout
      class CreateController < BaseController
        def call
          TokenAndCookiesCleaner.new(cookies).remove
          redirect_to callback_url
        end

        private

        def callback_url
          Stormpath::Rails::Client.application.create_id_site_url(callback_uri: id_site_result_url,
                                                                  logout: true)
        end
      end
    end
  end
end
