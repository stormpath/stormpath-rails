module Stormpath
  module Rails
    module Register
      class NewController < BaseController
        def call
          if stormpath_config.web.id_site.enabled
            redirect_to id_site_register_url
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
