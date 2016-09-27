module Stormpath
  module Rails
    module IdSiteLogout
      class CreateController < BaseController
        def call
          begin
            jwt = PayloadBuilder.new(:logout, cb_uri: root_url).jwt
            TokenAndCookiesCleaner.new(cookies).remove
            redirect_to "https://api.stormpath.com/sso/logout?jwtRequest=#{jwt}"
          rescue Stormpath::Error, LoginForm::FormError => error
          end
        end
      end
    end
  end
end
