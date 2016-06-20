module Stormpath
  module Rails
    class RefreshTokenAuthentication
      include ActiveModel::Model
      attr_accessor :refresh_token

      validates :refresh_token, presence: true

      class FormError < ArgumentError
        def status
          400
        end
      end

      def save!
        raise(FormError, errors.full_messages.first) if invalid?
        Client.application.authenticate_oauth(refresh_grant_request)
      end

      private

      def refresh_grant_request
        Stormpath::Oauth::RefreshGrantRequest.new(refresh_token)
      end
    end
  end
end
