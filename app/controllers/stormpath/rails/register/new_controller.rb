module Stormpath
  module Rails
    module Register
      class NewController < BaseController

        def call
          if stormpath_config.web.id_site.enabled
            redirect_to(stormpath_id_site_register_url)
          elsif signed_in?
            redirect_to(root_path)
          elsif organization_unresolved?
            redirect_to(parent_register_url)
          else
            respond_to do |format|
              format.json { render json: RegistrationFormSerializer.to_h }
              format.html { render stormpath_config.web.register.view }
            end
          end
        end

        private

        def stormpath_id_site_register_url
          Stormpath::Rails::Client.application.create_id_site_url(
            callback_uri: id_site_result_url,
            path: Stormpath::Rails.config.web.id_site.register_uri
          )
        end

        def parent_register_url
          UrlBuilder.create(
            req,
            stormpath_config.web.domain_name,
            stormpath_config.web.register.uri
          )
        end
      end
    end
  end
end
