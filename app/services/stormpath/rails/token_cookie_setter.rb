module Stormpath
  module Rails
    class TokenCookieSetter
      attr_reader :cookie_jar, :access_token, :refresh_token, :token_duration

      def self.call(cookie_jar, authentication_result)
        new(cookie_jar, authentication_result).call
      end

      def initialize(cookie_jar, authentication_result)
        @cookie_jar     = cookie_jar
        @access_token   = authentication_result.access_token
        @refresh_token  = authentication_result.refresh_token
        @token_duration = authentication_result.expires_in
      end

      def call
        cookie_jar[access_token_cookie_config.name]  = access_token_cookie_data
        cookie_jar[refresh_token_cookie_config.name] = refresh_token_cookie_data
      end

      private

      def access_token_cookie_data
        {
          value: access_token,
          expires: access_token_expiration_datetime,
          httponly: access_token_cookie_config.http_only,
          path: access_token_cookie_config.domain,
          secure: access_token_cookie_config.secure
        }
      end

      def refresh_token_cookie_data
        {
          value: refresh_token,
          expires: refresh_token_expiration_datetime,
          httponly: refresh_token_cookie_config.http_only,
          path: refresh_token_cookie_config.domain,
          secure: refresh_token_cookie_config.secure
        }
      end

      def access_token_expiration_datetime
        Time.zone.at(JWT.decode(access_token, ENV['STORMPATH_API_KEY_SECRET']).first['exp'])
      end

      def refresh_token_expiration_datetime
        Time.zone.at(JWT.decode(refresh_token, ENV['STORMPATH_API_KEY_SECRET']).first['exp'])
      end

      def access_token_cookie_config
        Stormpath::Rails.config.web.access_token_cookie
      end

      def refresh_token_cookie_config
        Stormpath::Rails.config.web.refresh_token_cookie
      end
    end
  end
end
