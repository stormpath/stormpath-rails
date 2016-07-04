module Stormpath
  module Rails
    module ChangePassword
      class CreateController < Stormpath::Rails::BaseController
        def call
          password_change.call
          respond_with_success
        rescue Stormpath::Error => error
          respond_to_stormpath_error(error)
        rescue InvalidSptokenError => error
          respond_with_error(error, configuration.web.change_password.error_uri)
        rescue NoSptokenError => error
          respond_with_error(error, configuration.web.forgot_password.uri)
        end

        private

        def password_change
          @password_change ||= PasswordChange.new(params[:sptoken], params[:password])
        end

        def respond_with_success
          if configuration.web.change_password.auto_login
            AccountLogin.call(cookies, password_change.account.email, params[:password])
            respond_to_autologin
          else
            respond_without_login
          end
        end

        def respond_to_autologin
          respond_to do |format|
            format.html { redirect_to configuration.web.login.next_uri }
            format.json { render json: AccountSerializer.to_h(password_change.account) }
          end
        end

        def respond_without_login
          respond_to do |format|
            format.html { redirect_to configuration.web.change_password.next_uri }
            format.json { render nothing: true, status: 200 }
          end
        end

        def respond_to_stormpath_error(error)
          respond_to do |format|
            format.html do
              flash.now[:error] = error.message
              render 'change_password/new'
            end
            format.json do
              render json: { status: error.status, message: error.message }, status: error.status
            end
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
