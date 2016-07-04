module Stormpath
  module Rails
    module ForgotPassword
      class CreateController < Stormpath::Rails::BaseController
        def call
          begin
            SendPasswordResetEmail.new(params[:email]).call
            respond_with_success
          rescue SendPasswordResetEmail::UnexistingEmailError
            respond_with_success
          rescue SendPasswordResetEmail::NoEmailError => error
            respond_with_error(error)
          end
        end

        private

        def respond_with_success
          respond_to do |format|
            format.html { redirect_to configuration.web.forgot_password.next_uri }
            format.json { render nothing: true, status: 200 }
          end
        end

        def respond_with_error(error)
          respond_to do |format|
            format.json { render json: { status: 400, message: error.message }, status: 400 }
            format.html do
              flash.now[:error] = error.message
              render 'forgot_password/new'
            end
          end
        end
      end
    end
  end
end
