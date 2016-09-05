module Stormpath
  module Rails
    class FacebookAuthCodeExchange
      FACEBOOK_EXCHANGE_URL = URI('https://graph.facebook.com/v2.7/oauth/access_token')

      attr_reader :root_url, :code

      def initialize(root_url, code)
        raise(NoFacebookAuthorizationError) if code.nil?
        @root_url = root_url
        @code = code
      end

      def access_token
        @access_token ||= fetch_access_token(exchange_auth_code.body)
      end

      private

      def exchange_auth_code
        http_client.post(FACEBOOK_EXCHANGE_URL, encoded_params)
      end

      def fetch_access_token(response_body)
        JSON.parse(response_body)['access_token']
      end

      def encoded_params
        URI.encode_www_form(
          client_id: Stormpath::Rails.config.web.facebook_app_id,
          client_secret: Stormpath::Rails.config.web.facebook_app_secret,
          redirect_uri: "#{root_url[0...-1]}#{Stormpath::Rails.config.web.social.facebook.uri}",
          code: code
        )
      end

      def http_client
        client = Net::HTTP.new(FACEBOOK_EXCHANGE_URL.host, FACEBOOK_EXCHANGE_URL.port)
        client.use_ssl = true
        client
      end

      class NoFacebookAuthorizationError < ArgumentError
        def message
          ''
        end
      end
    end
  end
end
