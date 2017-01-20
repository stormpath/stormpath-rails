module Stormpath
  module Rails
    module IdSiteCallback
      class NewController < BaseController

        def call
          begin
            if id_site_result.status == 'LOGOUT'
              TokenAndCookiesCleaner.new(cookies).remove
            else
              login_the_account
            end

            respond_with_success
          rescue Stormpath::Error, JWT::VerificationError => error
            respond_with_error(error)
          end
        end

        private

        def login_the_account
          AccountLoginWithStormpathToken.new(
            cookies, account,
            Stormpath::Rails::Client.application,
            Stormpath::Rails::Client.client.data_store.api_key
          ).call
        end

        def respond_with_success
          if id_site_result.status == 'LOGOUT'
            respond_to do |format|
              format.html { redirect_to stormpath_config.web.logout.next_uri, notice: 'Successfully logged out' }
              format.json { head :no_content }
            end
          else
            respond_to do |format|
              format.html { redirect_to login_redirect_route, notice: 'Successfully signed in' }
              format.json { render json: AccountSerializer.to_h(account) }
            end
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

        def id_site_result
          @id_site_result ||= Stormpath::Rails::Client.application.handle_id_site_callback(request.url)
        end

        def account
          @account ||= Stormpath::Rails::Client.client.accounts.get(id_site_result.account_href)
        end
      end
    end
  end
end
