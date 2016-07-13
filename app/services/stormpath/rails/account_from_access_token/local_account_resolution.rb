module Stormpath
  module Rails
    class AccountFromAccessToken
      class LocalAccountResolution
        attr_reader :access_token

        def initialize(access_token)
          @access_token = access_token
          @application = Client.application
        end

        def account
          Stormpath::Rails::Client.client.accounts.get(account_href)
        end

        def account_href
          jwt_response['sub']
        end

        def jwt_response
          jwt_data = JWT.decode(access_token, ENV['STORMPATH_API_KEY_SECRET'])
          if jwt_data.second['stt'] != 'access'
            raise AuthenticationWithRefreshTokenAttemptError
          end
          jwt_data.first
        rescue JWT::ExpiredSignature
          raise Stormpath::Oauth::Error, :jwt_expired
        end
      end
    end
  end
end
