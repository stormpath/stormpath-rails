module Stormpath
  module Rails
    class AccountSerializer
      attr_reader :account

      def self.to_h(account)
        new(account).to_h
      end

      def initialize(account)
        @account = account
      end

      def to_h
        {
          account: {
            href: account.href,
            username: account.username,
            modifiedAt: account.modified_at,
            status: account.status,
            createdAt: account.created_at,
            email: account.email,
            middleName: account.middle_name,
            surname: account.surname,
            givenName: account.given_name,
            fullName: account.full_name
          }
        }
      end
    end
  end
end
