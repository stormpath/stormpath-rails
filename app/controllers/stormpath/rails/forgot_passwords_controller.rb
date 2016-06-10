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
        reset_password(params[:email])

        respond_to do |format|
          format.json { render nothing: true, status: 200 }
          format.html { redirect_to configuration.web.forgot_password.next_uri }
        end
      end
    end
  end
end
