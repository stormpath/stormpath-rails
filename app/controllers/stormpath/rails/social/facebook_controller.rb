module Stormpath
  module Rails
    module Social
      class FacebookController < Stormpath::Rails::BaseController
        def create
          begin
            access_token = AuthorizationCodeExchanger.new(:facebook, root_url, params).access_token
            request = Stormpath::Provider::AccountRequest.new(:facebook, :access_token, access_token)
            account = Stormpath::Rails::Client.application.get_provider_account(request).account
            login_the_account(account)
            respond_with_success
          rescue InvalidSptokenError, NoSptokenError => error
            respond_with_error(error)
          end
        end

        private

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
            format.html { render stormpath_config.web.login.view }
            format.json do
              render json: { status: error.status, message: error.message }, status: error.status
            end
          end
        end
      end
    end
  end
end
