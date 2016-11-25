module Stormpath
  module Rails
    module Register
      class CreateController < BaseController
        def call
          form.save!
          login_the_account if auto_login_enabled? && !email_verification_enabled?
          respond_with_success
        rescue RegistrationForm::FormError => error
          respond_with_error(error)
        end

        private

        def respond_with_success
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
          @form ||= RegistrationForm.new(permitted_params)
        end

        def excluded_root_params
          [:controller, :action, :format, :create, :utf8, :button, :authenticity_token]
        end

        def permitted_params
          if stormpath_config.web.multi_tenancy.enabled
            params.except(*excluded_root_params).merge(organization_name_key: current_organization.name_key)
          else
            params.except(*excluded_root_params)
          end
        end

        def current_organization
          Stormpath::Rails::OrganizationResolver.new(req).organization
        end
        helper_method :current_organization

        def req
          request
        end
      end
    end
  end
end
