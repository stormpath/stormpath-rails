module Stormpath
  module Rails
    module Login
      class NewController < BaseController
        before_action :require_no_authentication!

        def call
          if stormpath_config.web.id_site.enabled
            callback_url = Stormpath::Rails::Client.application.create_id_site_url(
              callback_uri: id_site_result_url,
              path: Stormpath::Rails.config.web.id_site.login_uri
            )
            redirect_to callback_url
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
