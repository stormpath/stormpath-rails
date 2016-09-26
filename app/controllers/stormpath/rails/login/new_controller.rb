module Stormpath
  module Rails
    module Login
      class NewController < BaseController
        before_action :require_no_authentication!

        def call
          if stormpath_config.web.id_site.enabled
            payload = { 'iat' => Time.now.to_i,
                        'iss' => ENV['STORMPATH_API_KEY_ID'],
                        'sub' => ENV['STORMPATH_APPLICATION_URL'],
                        'cb_uri' => id_site_result_path,
                        'jti' => SecureRandom.uuid,
                        'path' => stormpath_config.web.id_site.loginUri,
                        'state' => '' }
            secret = ENV['STORMPATH_API_KEY_SECRET']
            jwt = JWT.encode(payload, secret, 'HS256')
            redirect_to "https://api.stormpath.com/sso?jwtRequest=#{jwt}"
          else
            respond_to do |format|
              format.json { render json: LoginNewSerializer.to_h }
              format.html { render stormpath_config.web.login.view }
            end
          end
        end
      end
    end
  end
end
