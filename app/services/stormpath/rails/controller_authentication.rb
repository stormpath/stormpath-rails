module Stormpath
  module Rails
    class ControllerAuthentication
      UnauthenticatedRequest = Class.new(StandardError)
      BEARER_PATTERN = /^Bearer /
      BASIC_PATTERN = /^Basic /
      ACCESS_TOKEN_COOKIE_NAME  = Stormpath::Rails.config.web.access_token_cookie.name
      REFRESH_TOKEN_COOKIE_NAME = Stormpath::Rails.config.web.refresh_token_cookie.name

      attr_reader :cookies, :authorization_header

      def initialize(cookies, authorization_header)
        @cookies = cookies
        @authorization_header = authorization_header
      end

      def authenticate!
        if any_auth_cookie_present?
          FromCookies.new(cookies).authenticate!
        elsif bearer_authorization_header?
          Stormpath::Authentication::HttpBearerAuthentication.new(
            Stormpath::Rails::Client.application,
            authorization_header,
            local: validation_strategy
          ).authenticate!.account
        elsif basic_authorization_header?
          Stormpath::Authentication::HttpBasicAuthentication.new(
            Stormpath::Rails::Client.application,
            authorization_header
          ).authenticate!.account
        else
          raise UnauthenticatedRequest
        end
      end

      private

      def bearer_authorization_header?
        authorization_header =~ BEARER_PATTERN
      end

      def any_auth_cookie_present?
        cookies[ACCESS_TOKEN_COOKIE_NAME] || cookies[REFRESH_TOKEN_COOKIE_NAME]
      end

      def basic_authorization_header?
        authorization_header =~ BASIC_PATTERN
      end

      def validation_strategy
        if Stormpath::Rails.config.web.oauth2.password.validation_strategy == 'stormpath'
          true
        else
          false
        end
      end
    end
  end
end
