module Stormpath
  module Rails
    module IdSiteLogout
      class NewController < BaseController
        def call
          jwt = PayloadBuilder.new(:logout, cb_uri: root_url).jwt
          TokenAndCookiesCleaner.new(cookies).remove
          redirect_to "https://api.stormpath.com/sso/logout?jwtRequest=#{jwt}"
        end
      end
    end
  end
end
