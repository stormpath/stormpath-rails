module Stormpath
  module Rails
    class Oauth2Controller < BaseController
      UnsupportedGrantType = Class.new(StandardError)

      def new
        render status: 405, nothing: true
      end

      def create
        response.headers['Cache-Control'] = 'no-cache, no-store'
        response.headers['Pragma'] = 'no-cache'

        case grant_type
        when 'client_credentials'
          handle_client_credentials_grant
        when 'password'
          handle_password_grant
        when 'refresh_token'
          handle_refresh_token_grant
        else
          if grant_type.blank?
            render json: { error: :invalid_request }, status: 400
          else
            fail UnsupportedGrantType
          end
        end
      rescue UnsupportedGrantType
        render json: { error: :unsupported_grant_type }, status: 400
      end

      private

      def grant_type
        params[:grant_type]
      end

      def handle_client_credentials_grant
        fail UnsupportedGrantType unless configuration.web.oauth2.client_credentials.enabled
      end

      def handle_password_grant
        fail UnsupportedGrantType unless configuration.web.oauth2.password.enabled
        begin
          form = LoginForm.new(login: params[:username], password: params[:password])
          auth_result = form.save!
          render json: auth_result_json(auth_result)
        rescue LoginForm::FormError, Stormpath::Error => error
          render json: {
            error: :invalid_request,
            message: error.message
          }, status: error.status
        end
      end

      def handle_refresh_token_grant
        fail UnsupportedGrantType unless configuration.web.oauth2.password.enabled
        begin
          form = RefreshTokenAuthentication.new(refresh_token: params[:refresh_token])
          auth_result = form.save!
          render json: auth_result_json(auth_result)
        rescue LoginForm::FormError, Stormpath::Error => error
          render json: {
            error: :invalid_grant,
            message: error.message
          }, status: error.status
        end
      end

      def auth_result_json(auth_result)
        {
          access_token: auth_result.access_token,
          expires_in: auth_result.expires_in,
          refresh_token: auth_result.refresh_token,
          token_type: auth_result.token_type
        }
      end
    end
  end
end
