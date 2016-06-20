module Stormpath
  module Testing
    module Helpers
      def create_test_account
        @test_account_result ||= begin
          result = Stormpath::Rails::Client.create_stormpath_account(FactoryGirl.attributes_for(:user))
          raise(result.error_message) unless result.success?
          result
        end
      end

      def delete_test_account
        if @test_account_result && @test_account_result.success?
          @test_account_result.response.delete
        end
      end

      def delete_account(email)
        Stormpath::Rails::Client.application.accounts.search(email: email).first.delete
      end
    end
  end
end
