module Stormpath
  module Rails
    module Social
      class GoogleController < Stormpath::Rails::Social::SocialController
        def create
          begin
            request = Stormpath::Provider::AccountRequest.new(:google, :code, params[:code])
            account = Stormpath::Rails::Client.application.get_provider_account(request).account
            login_the_account(account)
            respond_with_success
          rescue InvalidSptokenError, NoSptokenError => error
            respond_with_error(error)
          end
        end
      end
    end
  end
end
