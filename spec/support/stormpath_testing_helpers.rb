module Stormpath
  module Testing
    module Helpers
      def create_test_account
        @test_account_result ||= begin
          Stormpath::Rails::Client.application.accounts.create(
            Stormpath::Resource::Account.new(
              FactoryGirl.attributes_for(:user)
            )
          )
        end
      end

      def delete_test_account
        @test_account_result && @test_account_result.delete
      end

      def delete_account(email)
        Stormpath::Rails::Client.application.accounts.search(email: email).first.delete
      end
    end
  end
end
