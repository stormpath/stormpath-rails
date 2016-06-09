module Stormpath
  module Rails
    class DeleteAccessToken
      def self.call(token)
        new(token).call
      end

      def initialize(token)
        @token = token
      end

      def call
        token && delete_token
      end

      private

      def delete_token
        token_resource.delete
      rescue JWT::ExpiredSignature
      end

      def token_resource
        tokens_collection.get(token_unique_identifier)
      end

      def tokens_collection
        stormpath_client.access_tokens
      end

      def token_unique_identifier
        JWT.decode(token, api_key_secret).first['jti']
      end

      def api_key_secret
        stormpath_client.data_store.api_key.secret
      end

      def stormpath_client
        Stormpath::Rails::Client.client
      end

      private

      attr_reader(:token)
    end
  end
end
