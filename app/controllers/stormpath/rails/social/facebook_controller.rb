module Stormpath
  module Rails
    module Social
      class FacebookController < Stormpath::Rails::Social::SocialController
        def create
          begin
            access_token = FacebookAuthCodeExchange.new(root_url, params[:code]).access_token
            request = Stormpath::Provider::AccountRequest.new(:facebook, :access_token, access_token)
            account = Stormpath::Rails::Client.application.get_provider_account(request).account
            login_the_account(account)
            respond_with_success
          rescue NoFacebookAuthorizationError => error
            respond_with_error(error)
          end
        end
      end
    end
  end
end
