module Stormpath
  module Rails
    module Oauth2
      class CreateController < BaseController
        UnsupportedGrantType = Class.new(StandardError)

        def call
          response.headers['Cache-Control'] = 'no-store'
          response.headers['Pragma'] = 'no-cache'

          case grant_type
          when 'client_credentials'
            handle_client_credentials_grant
          when 'password'
            handle_password_grant
          when 'refresh_token'
            handle_refresh_token_grant
          else
            raise UnsupportedGrantType if grant_type.present?
            render json: { error: :invalid_request }, status: 400
          end
        rescue UnsupportedGrantType
          render json: { error: :unsupported_grant_type }, status: 400
        end

        private

        def grant_type
          params[:grant_type]
        end

        def handle_client_credentials_grant
          raise UnsupportedGrantType unless configuration.web.oauth2.client_credentials.enabled
          begin
            auth_result = ClientCredentialsAuthentication.new(request.headers['Authorization']).save!
            render json: auth_result_json(auth_result).except(:refresh_token)
          rescue ClientCredentialsAuthentication::FormError, Stormpath::Error => error
            render json: {
              error: :invalid_client,
              message: error.message
            }, status: 401
          end
        end

        def handle_password_grant
          raise UnsupportedGrantType unless configuration.web.oauth2.password.enabled
          begin
            auth_result = LoginForm.new(params[:username], params[:password]).save!
            render json: auth_result_json(auth_result)
          rescue LoginForm::FormError, Stormpath::Error => error
            render json: {
              error: :invalid_request,
              message: error.message
            }, status: error.status
          end
        end

        def handle_refresh_token_grant
          raise UnsupportedGrantType unless configuration.web.oauth2.password.enabled
          begin
            auth_result = RefreshTokenAuthentication.new(params[:refresh_token]).save!
            render json: auth_result_json(auth_result)
          rescue RefreshTokenAuthentication::FormError, Stormpath::Error => error
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
end
