module Stormpath
  module Rails
    module Social
      class GithubController < Stormpath::Rails::Social::SocialController
        def create
          begin
            access_token = GithubAuthCodeExchange.new(root_url, params[:code]).access_token
            request = Stormpath::Provider::AccountRequest.new(:github, :access_token, access_token)
            account = Stormpath::Rails::Client.application.get_provider_account(request).account
            login_the_account(account)
            respond_with_success
          rescue NoGithubAuthorizationError => error
            respond_with_error(error)
          end
        end
      end
    end
  end
end
