module Stormpath
  module Rails
    module Social
      class SocialController < Stormpath::Rails::BaseController
        def login_the_account(account)
          AccountLoginWithStormpathToken.new(
            cookies, account,
            Stormpath::Rails::Client.application,
            Stormpath::Rails::Client.client.data_store.api_key
          ).call
        end

        def respond_with_success
          respond_to do |format|
            format.json { render nothing: true, status: :ok }
            format.html { redirect_to stormpath_config.web.login.next_uri }
          end
        end

        def respond_with_error(error)
          respond_to do |format|
            format.html do
              flash.now[:error] = "An error occured and we couldn't log you in"
              render stormpath_config.web.login.view
            end
            format.json do
              render json: { status: error.status, message: error.message }, status: error.status
            end
          end
        end
      end
    end
  end
end
