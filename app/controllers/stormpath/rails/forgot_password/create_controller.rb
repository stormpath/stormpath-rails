module Stormpath
  module Rails
    module ForgotPassword
      class CreateController < Stormpath::Rails::BaseController
        def call
          reset_password(params[:email])

          respond_to do |format|
            format.json { render nothing: true, status: 200 }
            format.html { redirect_to configuration.web.forgot_password.next_uri }
          end
        end
      end
    end
  end
end
