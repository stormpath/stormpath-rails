module Stormpath
  module Rails
    class PasswordChange
      attr_reader :account, :password

      def initialize(sptoken, password)
        @account = SptokenVerification.new(sptoken).call
        @password = password
      end

      def call
        account.password = password
        account.save
      end
    end
  end
end
