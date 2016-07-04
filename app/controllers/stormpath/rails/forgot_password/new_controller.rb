module Stormpath
  module Rails
    module ForgotPassword
      class NewController < Stormpath::Rails::BaseController
        def call
          respond_to do |format|
            format.json { render nothing: true, status: 404 }
            format.html { render configuration.web.forgot_password.view }
          end
        end
      end
    end
  end
end
