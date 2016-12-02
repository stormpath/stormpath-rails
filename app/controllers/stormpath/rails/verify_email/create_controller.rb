module Stormpath
  module Rails
    module VerifyEmail
      class CreateController < BaseController
        def call
          begin
            if organization_resolution?
              OrganizationForm.new(params[:organization_name_key]).save!
            else
              ResendEmailVerification.new(params[:email], current_organization).call
            end
            respond_with_success
          rescue ResendEmailVerification::UnexistingEmailError
            respond_with_success
          rescue ResendEmailVerification::NoEmailError, Stormpath::Rails::OrganizationForm::FormError => error
            respond_with_error(error)
          end
        end

        private

        def respond_with_success
          return redirect_to subdomain_verify_email_url if organization_resolution?

          respond_to do |format|
            format.html { redirect_to "#{stormpath_config.web.login.uri}?status=unverified" }
            format.json { render nothing: true }
          end
        end

        def respond_with_error(error)
          respond_to do |format|
            format.json { render json: { status: 400, message: error.message }, status: 400 }
            format.html do
              flash.now[:error] = error.message
              render stormpath_config.web.verify_email.view
            end
          end
        end

        def subdomain_verify_email_url
          UrlBuilder.create(
            req,
            "#{params[:organization_name_key]}.#{stormpath_config.web.domain_name}",
            stormpath_config.web.verify_email.uri
          )
        end
      end
    end
  end
end
