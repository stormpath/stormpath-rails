module Stormpath
  module Rails
    module ForgotPassword
      class NewController < Stormpath::Rails::BaseController
        def call
          if organization_unresolved?
            redirect_to(parent_forgot_password_url)
          else
            respond_to do |format|
              format.json { render nothing: true, status: 404 }
              format.html { render stormpath_config.web.forgot_password.view }
            end
          end
        end

        private

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
