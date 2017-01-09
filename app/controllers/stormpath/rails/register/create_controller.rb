module Stormpath
  module Rails
    module Register
      class CreateController < BaseController
        def call
          form.save!
          login_the_account if valid_for_login?
          respond_with_success
        rescue RegistrationForm::FormError, OrganizationForm::FormError => error
          respond_with_error(error)
        end

        private

        def respond_with_success
          return redirect_to subdomain_register_url if organization_resolution?

          respond_to do |format|
            format.html { redirect_to success_redirect_route }
            format.json { render json: serialized_account }
          end
        end

        def success_redirect_route
          if email_verification_enabled?
            success_with_email_verification_redirect_route
          elsif auto_login_enabled?
            success_with_auto_login_redirect_route
          else
            default_success_redirect_route
          end
        end

        def success_with_email_verification_redirect_route
          "#{stormpath_config.web.login.uri}?status=unverified"
        end

        def success_with_auto_login_redirect_route
          stormpath_config.web.register.next_uri
        end

        def default_success_redirect_route
          "#{stormpath_config.web.login.uri}?status=created"
        end

        def respond_with_error(error)
          respond_to do |format|
            format.json { respond_with_json_error(error) }
            format.html { respond_with_html_error(error) }
          end
        end

        def respond_with_json_error(error)
          render json: { status: error.status, message: error.message }, status: error.status
        end

        def respond_with_html_error(error)
          flash.now[:error] = error.message
          render stormpath_config.web.register.view
        end

        def valid_for_login?
          auto_login_enabled? && !email_verification_enabled? && !organization_resolution?
        end

        def auto_login_enabled?
          stormpath_config.web.register.auto_login
        end

        def email_verification_enabled?
          form.account.status == 'UNVERIFIED'
        end

        def serialized_account
          AccountSerializer.to_h(form.account)
        end

        def login_the_account
          AccountLogin.call(cookies, form.email, form.password)
        end

        def form
          @form ||= if organization_resolution?
                      OrganizationForm.new(params[:organization_name_key])
                    else
                      RegistrationForm.new(permitted_params)
                    end
        end

        def excluded_root_params
          [:controller, :action, :format, :create, :utf8, :button, :authenticity_token]
        end

        def permitted_params
          params.except(*excluded_root_params)
                .merge(organization_name_key: current_organization_name_key)
        end

        def subdomain_register_url
          UrlBuilder.create(
            req,
            "#{params[:organization_name_key]}.#{stormpath_config.web.domain_name}",
            stormpath_config.web.register.uri
          )
        end
      end
    end
  end
end
