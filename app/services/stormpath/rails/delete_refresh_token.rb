module Stormpath
  module Rails
    class DeleteRefreshToken < DeleteAccessToken
      private

      def tokens_collection
        stormpath_client.refresh_tokens
      end
    end
  end
end
