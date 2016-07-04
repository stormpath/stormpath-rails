module Stormpath
  module Rails
    module Login
      class NewController < BaseController
        before_action :require_no_authentication

        def call
          if configuration.web.id_site.enabled
            redirect_to id_site_login_url
          else
            respond_to do |format|
              format.json { render json: LoginNewSerializer.to_h }
              format.html { render configuration.web.login.view }
            end
          end
        end
      end
    end
  end
end
