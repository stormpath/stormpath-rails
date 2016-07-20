module Stormpath
  module Rails
    module Register
      class CreateController < BaseController
        def call
          form.save!
          login_the_account if auto_login_enabled?
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
            "#{stormpath_config.web.login.uri}?status=unverified"
          elsif auto_login_enabled?
            stormpath_config.web.register.next_uri
          else
            "#{stormpath_config.web.login.uri}?status=created"
          end
        end

        def respond_with_error(error)
          respond_to do |format|
            format.json do
              render json: { status: error.status, message: error.message }, status: error.status
            end
            format.html do
              flash.now[:error] = error.message
              render stormpath_config.web.register.view
            end
          end
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
          @form ||= RegistrationForm.new(params.except(*excluded_root_params))
        end

        def excluded_root_params
          [:controller, :action, :format, :create, :utf8, :button, :authenticity_token]
        end
      end
    end
  end
end
