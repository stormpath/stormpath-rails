module Stormpath
  module Rails
    class AccountFromAccessToken
      class StormpathAccountResolution
        attr_reader :access_token, :application

        def initialize(access_token)
          @access_token = access_token
          @application = Client.application
          validate_jwt_is_access_token
        end

        def account
          Stormpath::Oauth::VerifyAccessToken.new(application).verify(access_token).account
        end

        def validate_jwt_is_access_token
          raise AuthenticationWithRefreshTokenAttemptError if jwt_data.second['stt'] != 'access'
        end

        def jwt_data
          @jwt_data ||= JWT.decode(access_token, ENV['STORMPATH_API_KEY_SECRET'])
        end
      end
    end
  end
end
