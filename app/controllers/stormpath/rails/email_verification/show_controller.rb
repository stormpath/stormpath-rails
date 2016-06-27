module Stormpath
  module Rails
    module EmailVerification
      class ShowController < BaseController
        def call
          VerifyEmailToken.new(params[:sptoken]).call

          respond_to do |format|
            format.html { redirect_to configuration.web.verify_email.next_uri }
            format.json { render nothing: true, status: 200 }
          end
        rescue VerifyEmailToken::InvalidSptokenError => error
          respond_to do |format|
            format.html do
              flash.now[:error] = 'This verification link is no longer valid. Please request a new link from the form below.'
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
    end
  end
end
