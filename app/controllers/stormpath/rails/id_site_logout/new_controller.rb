module Stormpath
  module Rails
    module IdSiteLogout
      class NewController < BaseController
        def call
          callback_url = Stormpath::Rails::Client.application.create_id_site_url(
            callback_uri: root_url,
            logout: true
          )
          TokenAndCookiesCleaner.new(cookies).remove
          redirect_to callback_url
        end
      end
    end
  end
end
