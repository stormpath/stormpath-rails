module Stormpath
  module Rails
    module EmailVerification
      class ShowController < BaseController
        def call
          begin
            account = VerifyEmailToken.new(params[:sptoken]).call
            login_the_account(account) if configuration.web.register.auto_login
            respond_with_success
          rescue InvalidSptokenError, NoSptokenError => error
            respond_to_error(error)
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

        def respond_with_success
          respond_to do |format|
            format.html { redirect_to success_redirect_route }
            format.json { render nothing: true, status: 200 }
          end
        end

        def success_redirect_route
          if configuration.web.register.auto_login
            configuration.web.register.next_uri
          else
            configuration.web.verify_email.next_uri
          end
        end

        def respond_to_error(error)
          respond_to do |format|
            format.html { render configuration.web.verify_email.view }
            format.json do
              render json: { status: error.status, message: error.message }, status: error.status
            end
          end
        end
      end
    end
  end
end
