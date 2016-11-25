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
        Stormpath::Rails::Client.application
      end

      def test_client
        Stormpath::Rails::Client.client
      end

      def map_account_store(app, store, index, default_account_store, default_group_store)
        test_client.account_store_mappings.create(
          application: app,
          account_store: store,
          list_index: index,
          is_default_account_store: default_account_store,
          is_default_group_store: default_group_store
        )
      end

      def map_organization_store(account_store, organization, default_account_store = false)
        test_client.organization_account_store_mappings.create(
          account_store: { href: account_store.href },
          organization: { href: organization.href },
          is_default_account_store: default_account_store
        )
      end

      def default_domain
        '@testmail.stormpath.com'
      end

      def random_name
        "rails-#{SecureRandom.hex(10)}"
      end
    end
  end
end
