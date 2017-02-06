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
          rescue Stormpath::Error, LoginForm::FormError, SocialLoginForm::FormError,
                 OrganizationForm::FormError, OrganizationResolver::Error => error
            respond_with_error(error)
          end
        end

        private

        def form
          @form ||= if social_login?
                      SocialLoginForm.new(provider, access_token, cookies)
                    elsif organization_resolution?
                      OrganizationForm.new(params[:organization_name_key])
                    else
                      LoginForm.new(params[:login],
                                    params[:password],
                                    organization_name_key: current_organization.try(:name_key))
                    end
        end

        def respond_with_success
          return redirect_to subdomain_login_url if organization_resolution?

          respond_to do |format|
            format.html { redirect_to login_redirect_route, notice: 'Successfully signed in' }
            format.json { render json: serialized_account }
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
          params[:next] ? URI(params[:next]).path : stormpath_config.web.login.next_uri
        end

        def provider
          params[:providerData][:providerId]
        end

        def access_token
          params[:providerData][:accessToken]
        end

        def account_login?
          !social_login? && !organization_resolution?
        end

        def social_login?
          params[:providerData].present?
        end

        def subdomain_login_url
          UrlBuilder.create(
            req,
            "#{params[:organization_name_key]}.#{stormpath_config.web.domain_name}",
            stormpath_config.web.login.uri
          )
        end
      end
    end
  end
end
