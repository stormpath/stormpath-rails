module Stormpath
  module Rails
    module Register
      class NewController < BaseController
        def call
          if stormpath_config.web.id_site.enabled
            payload = { 'iat' => Time.now.to_i,
                        'iss' => ENV['STORMPATH_API_KEY_ID'],
                        'sub' => ENV['STORMPATH_APPLICATION_URL'],
                        'cb_uri' => id_site_result_url,
                        'jti' => SecureRandom.uuid,
                        'path' => stormpath_config.web.id_site.registerUri,
                        'state' => '' }
            secret = ENV['STORMPATH_API_KEY_SECRET']
            jwt = JWT.encode(payload, secret, 'HS256')
            redirect_to "https://api.stormpath.com/sso?jwtRequest=#{jwt}"
          elsif signed_in?
            redirect_to root_path
          else
            respond_to do |format|
              format.json { render json: RegistrationFormSerializer.to_h }
              format.html { render stormpath_config.web.register.view }
            end
          end
        end
      end
    end
  end
end
