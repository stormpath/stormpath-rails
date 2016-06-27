module Stormpath
  module Rails
    module EmailVerification
      class CreateController < BaseController
        def call
          begin
            ResendEmailVerification.new(params[:email]).call
            respond_to do |format|
              format.html { redirect_to "#{configuration.web.login.uri}?status=unverified" }
              format.json { render nothing: true }
            end
          rescue ResendEmailVerification::UnexistingEmailError
            respond_to do |format|
              format.html { redirect_to "#{configuration.web.login.uri}?status=unverified" }
              format.json { render nothing: true }
            end
          rescue ResendEmailVerification::NoEmailError => error
            respond_to do |format|
              format.json { render json: { status: 400, message: error.message }, status: 400 }
              format.html do
                flash.now[:error] = error.message
                render template: 'email_verification/new'
              end
            end
          end
        end
      end
    end
  end
end
