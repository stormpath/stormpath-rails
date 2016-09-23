module Stormpath
  module Rails
    module IdSite
      class LoginController < BaseController
        before_action :require_no_authentication!

        def call
          begin
            jwt = JWT.decode(params[:jwtResponse], ENV['STORMPATH_API_KEY_SECRET'], 'HS256')
            account = Stormpath::Rails::Client.client.accounts.get(jwt.first['sub'])
            login_the_account(account)
            redirect_to root_path
          rescue Stormpath::Error, LoginForm::FormError => error
            binding.pry
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
      end
    end
  end
end
