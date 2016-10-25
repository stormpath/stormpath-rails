module Stormpath
  module Rails
    module Register
      class NewController < BaseController
        def call
          if stormpath_config.web.id_site.enabled
            callback_url = Stormpath::Rails::Client.application.create_id_site_url(
              callback_uri: id_site_result_url,
              path: Stormpath::Rails.config.web.id_site.register_uri
            )
            redirect_to callback_url
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
