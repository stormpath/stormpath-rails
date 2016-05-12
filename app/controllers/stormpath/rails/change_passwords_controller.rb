module Stormpath
  module Rails
    class ChangePasswordsController < Stormpath::Rails::BaseController

      def new
        result = verify_email_token params[:sptoken]

        if result.success?
          @account_url = result.account_url
          render template: "passwords/forgot_change"
        else
          render template: "passwords/forgot_change_failed"
        end
      end

      def create
        @account_url = params[:account_url]
        if passwords_match?
          result = update_password(params[:account_url], params[:password][:original])
          if result.success?
            render template: "passwords/forgot_complete"
          else
            set_flash_message :error, result.error_message
            render template: "passwords/forgot_change"
          end

        else
          set_flash_message :error, 'Passwords do not match.'
          render template: "passwords/forgot_change"
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
