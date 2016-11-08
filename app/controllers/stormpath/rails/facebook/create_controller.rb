module Stormpath
  module Rails
    module Facebook
      class CreateController < Stormpath::Rails::SocialController
        def call
          begin
            login_the_account(account)
            respond_with_success
          rescue NoFacebookAuthorizationError => error
            respond_with_error(error)
          end
        end

        private

        def access_token
          FacebookAuthCodeExchange.new(root_url, params[:code]).access_token
        end

        def account_request
          Stormpath::Provider::AccountRequest.new(:facebook, :access_token, access_token)
        end

        def account
          Stormpath::Rails::Client.application.get_provider_account(account_request).account
        end
      end
    end
  end
end
