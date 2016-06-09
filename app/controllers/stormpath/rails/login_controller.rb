module Stormpath
  module Rails
    class LoginController < BaseController
      before_action :redirect_signed_in_users, only: :new

      def create
        form = LoginForm.new(login: params[:login], password: params[:password])

        if form.invalid?
          return respond_to do |format|
            format.json do
              render json: { status: 400, message: form.errors.first }, status: 400
            end
            format.html do
              set_flash_message :error, form.errors.first
              render template: 'sessions/new'
            end
          end
        end

        result = authenticate_oauth(password_grant_request)

        if result.success?
          @user = find_or_create_user_from_account result.account

          TokenCookieSetter.call(cookies, result.authentication_result)

          respond_to do |format|
            format.json { render json: AccountSerializer.to_h(result.account) }
            format.html { redirect_to login_redirect_route, notice: 'Successfully signed in' }
          end
        else
          respond_to do |format|
            format.json do
              status = result.status.presence || 400
              render json: { status: status, message: result.error_message }, status: status
            end
            format.html do
              set_flash_message :error, result.error_message
              render template: 'sessions/new'
            end
          end
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

      def user_from_params
        username = params[:login]
        password = params[:password]

        ::User.new.tap do |user|
          user.email = username
          user.password = password
        end
      end

      def password_grant_request
        Stormpath::Oauth::PasswordGrantRequest.new(params[:login], params[:password])
      end

      def redirect_signed_in_users
        redirect_to root_path if signed_in?
      end

      def login_redirect_route
        if params[:next]
          login_redirect_route_from_params
        else
          configuration.web.login.next_uri
        end
      end

      def login_redirect_route_from_params
        if params[:next].start_with?('/')
          params[:next]
        else
          "/#{params[:next]}"
        end
      end
    end
  end
end
