module Stormpath
  module Rails
    module Social
      class LinkedinController < Stormpath::Rails::BaseController
        def create
          binding.pry
          request = Stormpath::Provider::AccountRequest.new(:linkedin, :access_token, params[:code])
          Stormpath::Rails.client.application.get_provider_account(request)
          respond_to do |format|
            format.json { render nothing: true, status: 404 }
            format.html { redirect_to stormpath_config.web.login.next_uri }
          end
        end
      end
    end
  end
end
