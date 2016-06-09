module Stormpath
  module Rails
    class LoginController < BaseController
      before_action :require_no_authentication, only: [:new, :create]

      def create
        form = LoginForm.new(login: params[:login], password: params[:password])

        if form.save
          TokenCookieSetter.call(cookies, form.authentication_result)

          respond_to do |format|
            format.json { render json: AccountSerializer.to_h(form.authentication_result.account) }
            format.html { redirect_to login_redirect_route, notice: 'Successfully signed in' }
          end
        else
          reply_with_error(form.errors.full_messages.first)
        end
      end

      def new
        if configuration.web.id_site.enabled
          redirect_to id_site_login_url
        else
          respond_to do |format|
            format.json { render json: LoginNewSerializer.to_h }
            format.html { render template: 'sessions/new' }
          end
        end
      end

      def redirect
        user_data = handle_id_site_callback(request.url)
        @user = find_user_by_email user_data.email
        initialize_session(@user, user_data.href)

        redirect_to configuration.web.id_site.next_uri, notice: 'Successfully signed in'
      end

      private

      def reply_with_error(error_message)
        respond_to do |format|
          format.json { render json: { status: 400, message: error_message }, status: 400 }
          format.html do
            set_flash_message :error, error_message
            render template: 'sessions/new'
          end
        end
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
