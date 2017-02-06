module Stormpath
  module Rails
    module ForgotPassword
      class CreateController < Stormpath::Rails::BaseController
        def call
          begin
            if organization_resolution?
              OrganizationForm.new(params[:organization_name_key]).save!
            else
              SendPasswordResetEmail.new(params[:email], current_organization).call
            end
            respond_with_success
          rescue SendPasswordResetEmail::UnexistingEmailError
            respond_with_success
          rescue SendPasswordResetEmail::NoEmailError,
                 Stormpath::Rails::OrganizationForm::FormError => error
            respond_with_error(error)
          end
        end

        private

        def respond_with_success
          return redirect_to subdomain_forgot_password_url if organization_resolution?

          respond_to do |format|
            format.html { redirect_to stormpath_config.web.forgot_password.next_uri }
            format.json { render nothing: true, status: 200 }
          end
        end

        def respond_with_error(error)
          respond_to do |format|
            format.json { render json: { status: 400, message: error.message }, status: 400 }
            format.html do
              flash.now[:error] = error.message
              render stormpath_config.web.forgot_password.view
            end
          end
        end

        def subdomain_forgot_password_url
          UrlBuilder.create(
            req,
            "#{params[:organization_name_key]}.#{stormpath_config.web.domain_name}",
            stormpath_config.web.forgot_password.uri
          )
        end
      end
    end
  end
end
