module Stormpath
  module Rails
    module Login
      class NewController < BaseController
        before_action :require_no_authentication!

        def call
          if stormpath_config.web.id_site.enabled
            jwt = PayloadBuilder.new(:login, cb_uri: id_site_result_url).jwt
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
