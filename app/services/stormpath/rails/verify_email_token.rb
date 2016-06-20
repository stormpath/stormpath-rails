module Stormpath
  module Rails
    class VerifyEmailToken
      attr_reader :sptoken

      def initialize(sptoken)
        raise(NoSptokenError, 'sptoken parameter not provided.') if sptoken.nil?
        @sptoken = sptoken
      end

      def call
        begin
          client.accounts.verify_email_token(sptoken)
        rescue Stormpath::Error => error
          raise if error.code != 404
          raise InvalidSptokenError, error.message
        end
      end

      private

      def client
        Stormpath::Rails::Client.client
      end

      NoSptokenError = Class.new(ArgumentError)
      InvalidSptokenError = Class.new(ArgumentError)
    end
  end
end
