module Stormpath
  module Rails
    module ForgotPassword
      class NewController < Stormpath::Rails::BaseController
        def call
          if stormpath_config.web.id_site.enabled
            redirect_to(stormpath_id_site_forgot_password_url)
          elsif organization_unresolved?
            redirect_to(parent_forgot_password_url)
          else
            respond_to do |format|
              format.json { render nothing: true, status: 404 }
              format.html { render stormpath_config.web.forgot_password.view }
            end
          end
        end

        private

        def stormpath_id_site_forgot_password_url
          Stormpath::Rails::Client.application.create_id_site_url(
            callback_uri: id_site_result_url,
            path: Stormpath::Rails.config.web.id_site.forgot_uri
          )
        end

        def parent_forgot_password_url
          UrlBuilder.create(
            req,
            stormpath_config.web.domain_name,
            stormpath_config.web.forgot_password.uri
          )
        end
      end
    end
  end
end
