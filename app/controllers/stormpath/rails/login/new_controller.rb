module Stormpath
  module Rails
    module Login
      class NewController < BaseController
        before_action :require_no_authentication!

        def call
          redirect_to callback_url if stormpath_config.web.id_site.enabled

          if should_resolve_organization?
            if current_organization.nil?
              redirect_to parent_login_url
              return
            end
          end

          respond_to do |format|
            format.json { render json: LoginNewSerializer.to_h }
            format.html { render stormpath_config.web.login.view }
          end
        end

        private

        def callback_url
          Stormpath::Rails::Client.application.create_id_site_url(
            callback_uri: id_site_result_url,
            path: Stormpath::Rails.config.web.id_site.login_uri
          )
        end

        def req
          request
        end

        def should_resolve_organization?
          stormpath_config.web.multi_tenancy.enabled &&
            req.host != stormpath_config.web.domain_name
        end

        def current_organization
          Stormpath::Rails::OrganizationResolver.new(req).organization
        end
        helper_method :current_organization

        def parent_login_url
          "#{req.scheme}://#{stormpath_config.web.domain_name}#{stormpath_config.web.login.uri}"
        end
      end
    end
  end
end
