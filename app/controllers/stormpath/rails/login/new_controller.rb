module Stormpath
  module Rails
    module Login
      class NewController < BaseController
        before_action :require_no_authentication!

        def call
          if stormpath_config.web.id_site.enabled
            return redirect_to(callback_url)
          elsif organization_unresolved?
            return redirect_to(parent_login_url)
          else
            respond_to do |format|
              format.json { render json: LoginNewSerializer.to_h }
              format.html { render stormpath_config.web.login.view }
            end
          end
        end

        private

        def callback_url
          Stormpath::Rails::Client.application.create_id_site_url(
            callback_uri: id_site_result_url,
            path: Stormpath::Rails.config.web.id_site.login_uri
          )
        end

        def parent_login_url
          UrlBuilder.create(
            req,
            stormpath_config.web.domain_name,
            stormpath_config.web.login.uri
          )
        end
      end
    end
  end
end
