module Stormpath
  module Rails
    module ChangePassword
      class CreateController < Stormpath::Rails::BaseController
        def call
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
          respond_to do |format|
            format.html do
              flash.now[:error] = error.message
              render template: 'change_password/new'
            end
            format.json do
              render json: { status: error.status, message: error.message }, status: error.status
            end
          end
        rescue InvalidSptokenError => error
          respond_to do |format|
            format.html { redirect_to configuration.web.change_password.error_uri }
            format.json do
              render json: { status: error.status, message: error.message }, status: error.status
            end
          end
        rescue NoSptokenError => error
          respond_to do |format|
            format.html { redirect_to configuration.web.forgot_password.uri }
            format.json do
              render json: { status: error.status, message: error.message }, status: error.status
            end
          end
        end
      end
    end
  end
end
