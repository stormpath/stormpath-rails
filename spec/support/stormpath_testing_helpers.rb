module Stormpath
  module Testing
    module Helpers
      def create_test_account
        @test_account_result ||= begin
          Stormpath::Rails::Client.application.accounts.create(
            Stormpath::Resource::Account.new(
              FactoryGirl.attributes_for(:account)
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

      def test_application
        Stormpath::Rails::Client.client.applications.get(ENV['STORMPATH_APPLICATION_HREF'] || ENV['STORMPATH_APPLICATION_URL'])
      end

      def default_domain
        '@testmail.stormpath.com'
      end
    end
  end
end
