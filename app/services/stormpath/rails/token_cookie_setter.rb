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
      expires: expires,
      httponly: http_only,
      path: path,
      domain: domain,
      secure: secure
    }.compact
  end

  def expires
    Time.zone.at(JWT.decode(token, ENV['STORMPATH_API_KEY_SECRET']).first['exp'])
  end

  def http_only
    if token_config.http_only == false
      nil
    else
      true
    end
  end

  def path
    token_config.path || '/'
  end

  def domain
    token_config.domain
  end

  def secure
    token_config.secure || false
  end
end
# check for domain and https true
