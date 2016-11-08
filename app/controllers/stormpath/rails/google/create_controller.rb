module Stormpath
  module Rails
    module Google
      class CreateController < Stormpath::Rails::SocialController
        def call
          begin
            login_the_account(account)
            respond_with_success
          rescue InvalidSptokenError, NoSptokenError => error
            respond_with_error(error)
          end
        end

        private

        def account_request
          Stormpath::Provider::AccountRequest.new(:google, :code, params[:code])
        end

        def account
          Stormpath::Rails::Client.application.get_provider_account(account_request).account
        end
      end
    end
  end
end
