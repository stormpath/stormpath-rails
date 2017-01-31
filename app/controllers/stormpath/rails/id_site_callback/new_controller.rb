module Stormpath
  module Rails
    module IdSiteCallback
      class NewController < BaseController

        def call
          begin
            if id_site_result.status == 'LOGOUT'
              TokenAndCookiesCleaner.new(cookies).remove
            elsif id_site_result.status == 'AUTHENTICATED'
              login_account_and_set_cookies
            elsif id_site_result.status == 'REGISTERED'
              login_account_and_set_cookies if valid_for_login?
            end

            respond_with_success
          rescue Stormpath::Error, JWT::VerificationError => error
            respond_with_error(error)
          end
        end

        private

        def login_account_and_set_cookies
          AccountLoginWithStormpathToken.new(
            cookies, account,
            Stormpath::Rails::Client.application,
            Stormpath::Rails::Client.client.data_store.api_key
          ).call
        end

        def respond_with_success
          if id_site_result.status == 'LOGOUT'
            respond_to do |format|
              format.html { redirect_to stormpath_config.web.logout.next_uri, notice: 'You have been logged out successfully.' }
              format.json { render nothing: true, status: 200 }
            end
          elsif id_site_result.status == 'AUTHENTICATED'
            respond_to do |format|
              format.html { redirect_to login_redirect_route, notice: 'Successfully signed in' }
              format.json { render json: serialized_account }
            end
          elsif id_site_result.status == 'REGISTERED'
            respond_to do |format|
              format.html { redirect_to register_redirect_route }
              format.json { render json: serialized_account }
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

        def valid_for_login?
          auto_login_enabled? && !email_verification_enabled?
        end

        def register_redirect_route
          if email_verification_enabled?
            "#{stormpath_config.web.login.uri}?status=unverified"
          elsif auto_login_enabled?
            stormpath_config.web.register.next_uri
          else
            "#{stormpath_config.web.login.uri}?status=created"
          end
        end

        def email_verification_enabled?
          account.status == 'UNVERIFIED'
        end

        def auto_login_enabled?
          stormpath_config.web.register.auto_login
        end

        def serialized_account
          AccountSerializer.to_h(account)
        end

        def login_redirect_route
          params[:next] ? URI(params[:next]).path : stormpath_config.web.login.next_uri
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
