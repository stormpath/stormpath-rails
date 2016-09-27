module Stormpath
  module Rails
    module IdSiteLogout
      class CreateController < BaseController
        def call
          begin
            payload = { 'iat' => Time.now.to_i,
                        'iss' => ENV['STORMPATH_API_KEY_ID'],
                        'sub' => ENV['STORMPATH_APPLICATION_URL'],
                        'cb_uri' => root_path,
                        'jti' => SecureRandom.uuid,
                        'path' => stormpath_config.web.id_site.loginUri,
                        'state' => '' }
            secret = ENV['STORMPATH_API_KEY_SECRET']
            jwt = JWT.encode(payload, secret, 'HS256')
            TokenAndCookiesCleaner.new(cookies).remove
            redirect_to "https://api.stormpath.com/sso/logout?jwtRequest=#{jwt}"
          rescue Stormpath::Error, LoginForm::FormError => error
          end
        end
      end
    end
  end
end
