module Stormpath
  module Rails
    module IdSite
      class LogoutController < BaseController
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
            delete_tokens
            delete_cookies
            redirect_to "https://api.stormpath.com/sso/logout?jwtRequest=#{jwt}"
          rescue Stormpath::Error, LoginForm::FormError => error
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
          stormpath_config.web.access_token_cookie.name
        end

        def refresh_token_cookie_name
          stormpath_config.web.refresh_token_cookie.name
        end
      end
    end
  end
end
