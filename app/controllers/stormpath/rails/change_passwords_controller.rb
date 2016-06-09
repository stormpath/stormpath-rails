module Stormpath
  module Rails
    class ChangePasswordsController < Stormpath::Rails::BaseController
      def new
        if params[:sptoken].present?
          result = verify_password_token params[:sptoken]

          if result.success?
            @sptoken = params[:sptoken]
            respond_to do |format|
              format.html { render template: 'passwords/forgot_change' }
              format.json { render nothing: true, status: 200 }
            end
          else
            respond_to do |format|
              format.html { redirect_to configuration.web.change_password.error_uri }
              format.json { render json: { status: 400, message: 'sptoken parameter not provided.' }, status: 400 }
            end
          end
        else
          respond_to do |format|
            format.html { redirect_to configuration.web.forgot_password.uri }
            format.json { render json: { status: 400, message: 'sptoken parameter not provided.' }, status: 400 }
          end
        end
      end

      def create
        @account_url = params[:account_url]
        if passwords_match?
          result = update_password(params[:account_url], params[:password][:original])
          if result.success?
            render template: 'passwords/forgot_complete'
          else
            set_flash_message :error, result.error_message
            render template: 'passwords/forgot_change'
          end

        else
          set_flash_message :error, 'Passwords do not match.'
          render template: 'passwords/forgot_change'
        end
      end

      private

      def password_params
        @password_params ||= params[:password] || params
      end

      def passwords_match?
        params[:password][:original] == params[:password][:repeated]
      end
    end
  end
end
