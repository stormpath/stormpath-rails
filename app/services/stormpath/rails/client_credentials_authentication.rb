module Stormpath
  module Rails
    class ClientCredentialsAuthentication
      include ActiveModel::Model
      BASIC_PATTERN = /^Basic /
      attr_accessor :api_key_id, :api_key_secret

      class FormError < ArgumentError
        def status
          400
        end
      end

      def initialize(authorization_header)
        raise FormError if authorization_header !~ BASIC_PATTERN

        self.api_key_id, self.api_key_secret = Base64.decode64(
          authorization_header.gsub(BASIC_PATTERN, '')
        ).split(':')
      end

      validates :api_key_id, presence: true
      validates :api_key_secret, presence: true

      def save!
        raise(FormError, errors.full_messages.first) if invalid?
        Client.application.authenticate_oauth(client_credentials_grant_request)
      end

      private

      def client_credentials_grant_request
        Stormpath::Oauth::ClientCredentialsGrantRequest.new(
          api_key_id,
          api_key_secret
        )
      end
    end
  end
end
