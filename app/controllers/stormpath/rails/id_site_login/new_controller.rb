module Stormpath
  module Rails
    module IdSiteLogin
      class NewController < BaseController
        before_action :require_no_authentication!

        def call
          begin
            result = Stormpath::Rails::Client.application.handle_id_site_callback(request.url)
            account = Stormpath::Rails::Client.client.accounts.get(result.account_href)
            login_the_account(account)
            respond_with_success(account)
          rescue Stormpath::Error => error
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

        def respond_with_success(account)
          respond_to do |format|
            format.html { redirect_to login_redirect_route, notice: 'Successfully signed in' }
            format.json { render json: AccountSerializer.to_h(account) }
          end
        end

        def respond_with_error(error)
          respond_to do |format|
            format.html do
              flash.now[:error] = error.message
              render stormpath_config.web.login.view
            end
            format.json do
              render json: { message: error.message }, status: error.try(:status)
            end
          end
        end

        def login_redirect_route
          if params[:next]
            URI(params[:next]).path
          else
            stormpath_config.web.login.next_uri
          end
        end
      end
    end
  end
end
