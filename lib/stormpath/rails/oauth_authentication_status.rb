module Stormpath
  module Rails
    class OauthAuthenticationStatus
      def initialize(response)
        @response = response
      end

      def success?
        @response.instance_of? Stormpath::Resource::AccessToken
      end

      def access_token
        @response
      end

      def account
        @account ||= Stormpath::Rails::Client.client.accounts.get(account_href)
      end

      def error_message
        if @response.instance_of? Stormpath::Error
          @response.message
        else
          ''
        end
      end

      def status
        if @response.instance_of? Stormpath::Error
          @response.status
        end
      end

      private

      def account_href
        @account_href ||= jwt_response['sub']
      end

      def jwt_response
        begin
          JWT.decode(access_token.access_token, Stormpath::Rails.config.api_key.secret).first
        rescue JWT::ExpiredSignature => error
          raise Stormpath::IdSite::Error.new(:jwt_expired)
        end
      end
    end
  end
end
