module Stormpath
  module Rails
    module ChangePassword
      class NewController < Stormpath::Rails::BaseController
        def call
          verify_sptoken
          respond_with_success
        rescue InvalidSptokenError => error
          respond_with_error(error, configuration.web.change_password.error_uri)
        rescue NoSptokenError => error
          respond_with_error(error, configuration.web.forgot_password.uri)
        end

        private

        def verify_sptoken
          ForgotPasswordTokenVerification.new(params[:sptoken]).call
        end

        def respond_with_success
          respond_to do |format|
            format.html { render configuration.web.change_password.view }
            format.json { render nothing: true, status: 200 }
          end
        end

        def respond_with_error(error, redirect_path)
          respond_to do |format|
            format.html { redirect_to redirect_path }
            format.json do
              render json: { status: error.status, message: error.message }, status: error.status
            end
          end
        end
      end
    end
  end
end
