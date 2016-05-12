module Stormpath
  module Rails
    class ForgotPasswordsController < Stormpath::Rails::BaseController
      def new
        respond_to do |format|
          format.json { render nothing: true, status: 404 }
          format.html { render template: 'passwords/forgot' }
        end
      end

      def create
        result = reset_password(password_params[:email])

        respond_to do |format|
          format.json { render nothing: true, status: 200 }
          format.html { redirect_to configuration.forgot_password.next_uri }
        end
      end

      def password_params
        @password_params ||= params[:password] || params
      end
    end
  end
end
