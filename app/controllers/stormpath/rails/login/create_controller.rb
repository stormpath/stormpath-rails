module Stormpath
  module Rails
    module Login
      class CreateController < BaseController
        before_action :require_no_authentication

        def call
          if form.save
            set_cookies
            respond_with_success
          else
            respond_with_error(form.errors.full_messages.first)
          end
        end

        private

        def form
          @form ||= LoginForm.new(login: params[:login], password: params[:password])
        end

        def respond_with_success
          respond_to do |format|
            format.html { redirect_to login_redirect_route, notice: 'Successfully signed in' }
            format.json { render json: serialized_account }
          end
        end

        def respond_with_error(error_message)
          respond_to do |format|
            format.html do
              flash.now[:error] = error_message
              render configuration.web.login.view
            end
            format.json { render json: { status: 400, message: error_message }, status: 400 }
          end
        end

        def set_cookies
          TokenCookieSetter.call(cookies, form.authentication_result)
        end

        def serialized_account
          AccountSerializer.to_h(form.authentication_result.account)
        end

        def login_redirect_route
          if params[:next]
            params[:next].start_with?('/') ? params[:next] : "/#{params[:next]}"
          else
            configuration.web.login.next_uri
          end
        end
      end
    end
  end
end
