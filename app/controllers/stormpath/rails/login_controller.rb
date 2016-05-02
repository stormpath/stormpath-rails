module Stormpath
  module Rails
    class LoginController < BaseController
      before_action :redirect_signed_in_users, only: :new
      before_action :inspect_for_missing_fields, only: :create

      def create
        result = authenticate user_from_params

        if result.success?
          @user = find_or_create_user_from_account result.account

          set_access_token_cookie
          set_refresh_token_cookie

          initialize_session(@user, result.account.href)

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
              render template: "sessions/new"
            end
          end
        end
      end

      def new
        if !configuration.login.enabled?
          redirect_to configuration.login.next_uri
        elsif configuration.id_site.enabled?
          redirect_to id_site_login_url
        else
          render template: "sessions/new"
        end
      end

      def redirect
        user_data = handle_id_site_callback(request.url)
        @user = find_user_by_email user_data.email
        initialize_session(@user, user_data.href)

        redirect_to configuration.id_site.next_uri, notice: 'Successfully signed in'
      end

      private

      def set_access_token_cookie
        cookies[configuration.access_token_cookie.name] = access_token_cookie_config
      end

      def access_token_cookie_config
        {
          value: access_token.access_token,
          expires: access_token.expires_in.seconds.from_now,
          httponly: configuration.access_token_cookie.http_only,
          path: configuration.access_token_cookie.domain,
          secure: configuration.access_token_cookie.secure
        }
      end

      def set_refresh_token_cookie
        cookies[configuration.refresh_token_cookie.name] = refresh_token_cookie_config
      end

      def refresh_token_cookie_config
        {
          value: access_token.refresh_token,
          expires: access_token.expires_in.seconds.from_now,
          httponly: configuration.refresh_token_cookie.http_only,
          path: configuration.refresh_token_cookie.domain,
          secure: configuration.refresh_token_cookie.secure
        }
      end

      def user_from_params
        username = params[:login]
        password = params[:password]

        ::User.new.tap do |user|
          user.email = username
          user.password = password
        end
      end

      def access_token
        @access_token ||= authenticate_oauth(password_grant_request)
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
          configuration.login.next_uri
        end
      end

      def login_redirect_route_from_params
        if params[:next].start_with?('/')
          params[:next]
        else
          "/#{params[:next]}"
        end
      end

      def inspect_for_missing_fields
        if params[:login].blank? && params[:password].blank?
          flash[:error] = "Login and password fields can't be blank"
          render template: "sessions/new"
        elsif params[:login].blank?
          flash[:error] = "Login field can't be blank"
          render template: "sessions/new"
        elsif params[:password].blank?
          flash[:error] = "Password field can't be blank"
          render template: "sessions/new"
        end
      end
    end
  end
end
