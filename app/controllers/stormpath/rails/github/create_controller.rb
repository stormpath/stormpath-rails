module Stormpath
  module Rails
    module Github
      class CreateController < Stormpath::Rails::SocialController
        def call
          begin
            login_the_account(account)
            respond_with_success
          rescue NoGithubAuthorizationError => error
            respond_with_error(error)
          end
        end

        private

        def access_token
          GithubAuthCodeExchange.new(root_url, params[:code]).access_token
        end

        def account_request
          Stormpath::Provider::AccountRequest.new(:github, :access_token, access_token)
        end

        def account
          Stormpath::Rails::Client.application.get_provider_account(account_request).account
        end
      end
    end
  end
end
