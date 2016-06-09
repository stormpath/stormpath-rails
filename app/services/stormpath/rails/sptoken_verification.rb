module Stormpath
  module Rails
    class SptokenVerification
      attr_reader :sptoken

      def initialize(sptoken)
        fail(NoSptokenError, 'sptoken parameter not provided.') if sptoken.nil?
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
