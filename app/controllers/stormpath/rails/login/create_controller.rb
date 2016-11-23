module Stormpath
  module Rails
    module Login
      class CreateController < BaseController
        before_action :require_no_authentication!

        def call
          begin
            form.save!
            set_cookies unless social_login?
            respond_with_success
          rescue Stormpath::Error, LoginForm::FormError, SocialLoginForm::FormError => error
            respond_with_error(error)
          end
        end

        private

        def form
          @form ||= if social_login?
                      SocialLoginForm.new(provider, access_token, cookies)
                    else
                      LoginForm.new(params[:login], params[:password], organization: organization)
                    end
        end

        def respond_with_success
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

        def social_login?
          params[:providerData].present?
        end

        def organization
          Stormpath::Rails::OrganizationResolver.new(request).organization if multitenancy.enabled
        end

        def multitenancy
          stormpath_config.web.multi_tenancy
        end
      end
    end
  end
end
