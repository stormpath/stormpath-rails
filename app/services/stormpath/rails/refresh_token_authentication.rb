module Stormpath
  module Rails
    class RefreshTokenAuthentication
      attr_reader :refresh_token

      def initialize(refresh_token)
        raise(FormError, "Refresh token can't be blank") if refresh_token.blank?
        @refresh_token = refresh_token
      end

      def save!
        Client.application.authenticate_oauth(refresh_grant_request)
      end

      private

      def refresh_grant_request
        Stormpath::Oauth::RefreshGrantRequest.new(refresh_token)
      end

      class FormError < ArgumentError
        def status
          400
        end
      end
    end
  end
end
