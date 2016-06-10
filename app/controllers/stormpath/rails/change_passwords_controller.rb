module Stormpath
  module Rails
    class ChangePasswordsController < Stormpath::Rails::BaseController
      def new
        SptokenVerification.new(params[:sptoken]).call

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

      def create
        password_change = PasswordChange.new(params[:sptoken], params[:password])
        password_change.call

        if configuration.web.change_password.auto_login
          AccountLogin.call(cookies, password_change.account.email, params[:password])
          respond_to do |format|
            format.html { redirect_to configuration.web.login.next_uri }
            format.json { render json: AccountSerializer.to_h(password_change.account) }
          end
        else
          respond_to do |format|
            format.html { redirect_to configuration.web.change_password.next_uri }
            format.json { render nothing: true, status: 200 }
          end
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
