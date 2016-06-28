module Stormpath
  module Rails
    module EmailVerification
      class ShowController < BaseController
        def call
          begin
            account = VerifyEmailToken.new(params[:sptoken]).call

            if configuration.web.register.auto_login
              login_the_account(account)
              respond_to do |format|
                format.html { redirect_to configuration.web.register.next_uri }
                format.json { render nothing: true, status: 200 }
              end
            else
              respond_to do |format|
                format.html { redirect_to configuration.web.verify_email.next_uri }
                format.json { render nothing: true, status: 200 }
              end
            end
          rescue VerifyEmailToken::InvalidSptokenError => error
            respond_to do |format|
              format.html do
                render template: 'email_verification/new'
              end
              format.json { render json: { status: 404, message: error.message }, status: 404 }
            end
          rescue VerifyEmailToken::NoSptokenError => error
            respond_to do |format|
              format.html { render template: 'email_verification/new' }
              format.json { render json: { status: 400, message: error.message }, status: 400 }
            end
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
