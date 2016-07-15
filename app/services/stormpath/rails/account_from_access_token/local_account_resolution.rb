module Stormpath
  module Rails
    class AccountFromAccessToken
      class LocalAccountResolution
        attr_reader :access_token

        def initialize(access_token)
          @access_token = access_token
          @application = Client.application
          validate_jwt
        end

        def account
          Stormpath::Rails::Client.client.accounts.get(account_href)
        end

        private

        def account_href
          jwt_data.first['sub']
        end

        def jwt_data
          begin
            @jwt_data ||= JWT.decode(access_token, ENV['STORMPATH_API_KEY_SECRET'])
          rescue JWT::ExpiredSignature
            raise Stormpath::Oauth::Error, :jwt_expired
          end
        end

        def validate_jwt
          validate_jwt_is_an_access_token
          validate_jwt_has_a_valid_issuer
        end

        def validate_jwt_has_a_valid_issuer
          return if jwt_data.first['iss'] == Stormpath::Rails::Client.application.href
          raise DifferentIssuerError
        end

        def validate_jwt_is_an_access_token
          return if jwt_data.second['stt'] == 'access'
          raise AuthenticationWithRefreshTokenAttemptError
        end
      end
    end
  end
end
