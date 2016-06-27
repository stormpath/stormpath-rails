module Stormpath
  module Rails
    module ChangePassword
      class NewController < Stormpath::Rails::BaseController
        def call
          ForgotPasswordTokenVerification.new(params[:sptoken]).call

          respond_to do |format|
            format.html { render template: 'passwords/forgot_change' }
            format.json { render nothing: true, status: 200 }
          end
        rescue Stormpath::Error => error
          status = error.status.presence || 400
          respond_to do |format|
            format.html { redirect_to configuration.web.change_password.error_uri }
            format.json { render json: { status: status, message: error.message }, status: status }
          end
        rescue NoSptokenError => error
          respond_to do |format|
            format.html { redirect_to configuration.web.forgot_password.uri }
            format.json { render json: { status: 400, message: error.message }, status: 400 }
          end
        end
      end
    end
  end
end
