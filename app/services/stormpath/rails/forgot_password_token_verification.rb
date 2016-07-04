module Stormpath
  module Rails
    class ForgotPasswordTokenVerification
      attr_reader :sptoken

      def initialize(sptoken)
        raise(NoSptokenError, 'sptoken parameter not provided.') if sptoken.nil?
        @sptoken = sptoken
      end

      def call
        begin
          account_from_token
        rescue Stormpath::Error => error
          raise if error.status != 404
          raise InvalidSptokenError, error.message
        end
      end

      private

      def account_from_token
        Stormpath::Rails::Client
          .application
          .password_reset_tokens
          .get(sptoken)
          .account
      end
    end
  end
end
