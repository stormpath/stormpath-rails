module Stormpath
  module Rails
    class TokenCookieSetter
      attr_reader :cookie_jar, :access_token, :refresh_token

      def self.call(cookie_jar, authentication_result)
        new(cookie_jar, authentication_result).call
      end

      def initialize(cookie_jar, authentication_result)
        @cookie_jar     = cookie_jar
        @access_token   = authentication_result.access_token
        @refresh_token  = authentication_result.refresh_token
      end

      def call
        SingleTokenCookieSetter.new(cookie_jar, access_token, access_token_cookie_config).call
        SingleTokenCookieSetter.new(cookie_jar, refresh_token, refresh_token_cookie_config).call
      end

      private

      def access_token_cookie_config
        Stormpath::Rails.config.web.access_token_cookie
      end

      def refresh_token_cookie_config
        Stormpath::Rails.config.web.refresh_token_cookie
      end
    end
  end
end

class SingleTokenCookieSetter
  attr_reader :cookie_jar, :token, :token_config

  def initialize(cookie_jar, token, token_config)
    @cookie_jar = cookie_jar
    @token = token
    @token_config = token_config
  end

  def call
    cookie_jar[token_config.name] = cookie_data
  end

  private

  def cookie_data
    {
      value: token,
      expires: token_expiration_datetime,
      httponly: token_config.http_only,
      path: token_config.domain,
      secure: token_config.secure
    }
  end

  def token_expiration_datetime
    Time.zone.at(JWT.decode(token, ENV['STORMPATH_API_KEY_SECRET']).first['exp'])
  end
end
