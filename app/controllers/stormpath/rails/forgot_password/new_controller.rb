module Stormpath
  module Rails
    module ForgotPassword
      class NewController < Stormpath::Rails::BaseController
        def call
          respond_to do |format|
            format.json { render nothing: true, status: 404 }
            format.html { render template: 'forgot_password/new' }
          end
        end
      end
    end
  end
end
