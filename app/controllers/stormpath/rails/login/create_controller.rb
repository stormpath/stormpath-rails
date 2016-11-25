module Stormpath
  module Rails
    module Login
      class CreateController < BaseController
        before_action :require_no_authentication!

        def call
          begin
            form.save!
            set_cookies if account_login?
            respond_with_success
          rescue Stormpath::Error, LoginForm::FormError, SocialLoginForm::FormError, OrganizationForm::FormError => error
            respond_with_error(error)
          end
        end

        private

        def form
          @form ||= if social_login?
                      SocialLoginForm.new(provider, access_token, cookies)
                    elsif organization_assessment?
                      OrganizationForm.new(params[:organization_name_key])
                    else
                      LoginForm.new(params[:login], params[:password], organization: current_organization)
                    end
        end

        def respond_with_success
          if organization_assessment?
            redirect_to subdomain_login_url
          else
            respond_to do |format|
              format.html { redirect_to login_redirect_route, notice: 'Successfully signed in' }
              format.json { render json: serialized_account }
            end
          end
        end

        def respond_with_error(error)
          respond_to do |format|
            format.html do
              flash.now[:error] = error.message
              render stormpath_config.web.login.view
            end
            format.json do
              render json: { status: error.status, message: error.message }, status: error.status
            end
          end
        end

        def set_cookies
          TokenCookieSetter.call(cookies, form.authentication_result)
        end

        def serialized_account
          AccountSerializer.to_h(form.account)
        end

        def login_redirect_route
          if params[:next]
            URI(params[:next]).path
          else
            stormpath_config.web.login.next_uri
          end
        end

        def provider
          params[:providerData][:providerId]
        end

        def access_token
          params[:providerData][:accessToken]
        end

        def account_login?
          !social_login? && !organization_assessment?
        end

        def social_login?
          params[:providerData].present?
        end

        def organization_assessment?
          params[:organization_name_key].present?
        end

        def current_organization
          if multitenancy.enabled
            Stormpath::Rails::OrganizationResolver.new(req, params[:organization_name_key])
                                                  .organization
          end
        end
        helper_method :current_organization

        def multitenancy
          stormpath_config.web.multi_tenancy
        end

        def subdomain_login_url
          "#{req.scheme}://#{params[:organization_name_key]}.#{stormpath_config.web.domain_name}#{stormpath_config.web.login.uri}"
        end

        def req
          request
        end
      end
    end
  end
end
