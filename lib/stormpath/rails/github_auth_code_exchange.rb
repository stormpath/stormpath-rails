module Stormpath
  module Rails
    class GithubAuthCodeExchange
      GITHUB_EXCHANGE_URL = URI('https://github.com/login/oauth/access_token')

      attr_reader :root_url, :code

      def initialize(root_url, code)
        raise(NoGithubAuthorizationError) if code.nil?
        @root_url = root_url
        @code = code
      end

      def access_token
        @access_token ||= fetch_access_token(exchange_auth_code.body)
      end

      private

      def exchange_auth_code
        http_client.post(GITHUB_EXCHANGE_URL, encoded_params, 'Accept' => 'application/json')
      end

      def fetch_access_token(response_body)
        JSON.parse(response_body)['access_token']
      end

      def encoded_params
        URI.encode_www_form(
          client_id: Stormpath::Rails.config.web.github_app_id,
          client_secret: Stormpath::Rails.config.web.github_app_secret,
          redirect_uri: URI.join(root_url, Stormpath::Rails.config.web.social.github.uri).to_s,
          code: code
        )
      end

      def http_client
        client = Net::HTTP.new(GITHUB_EXCHANGE_URL.host, GITHUB_EXCHANGE_URL.port)
        client.use_ssl = true
        client
      end
    end
  end
end
