module Stormpath
  module Rails
    class ForgotPasswordTokenVerification
      attr_reader :sptoken

      def initialize(sptoken)
        raise(NoSptokenError, 'sptoken parameter not provided.') if sptoken.nil?
        @sptoken = sptoken
      end

      def call
        Stormpath::Rails::Client
          .application
          .password_reset_tokens
          .get(sptoken)
          .account
      end
    end

    class NoSptokenError < ArgumentError; end
  end
end
