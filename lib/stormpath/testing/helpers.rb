module Stormpath
  module Testing
    module Helpers
      def sign_in
        create_test_account
        @controller.send(:authenticate, test_user)
        @controller.send(:initialize_session, test_user, @test_account_result.href)
        test_user
      end

      def create_test_account
        create_store_mapping
        @test_account_result ||= Stormpath::Rails::Client.create_stormpath_account(test_user)
      end

      def delete_test_account
        if @test_account_result && @test_account_result.success?
          @test_account_result.response.delete 
        end
      end

      def test_user
        factory = Stormpath::Rails.config.user_model.to_s.underscore.to_sym
        @test_user ||= FactoryGirl.create(factory)
        @test_user.attributes = @test_user.attributes.merge!("password" => @test_user.password)
        @test_user
      end

      def create_test_directory
        unless @test_directory
          @test_directory ||= Stormpath::Rails::Client.client.directories.create(name: 'test-directory')
        end
      end

      def delete_test_directory
        @test_directory.delete if @test_directory
      end

      def create_store_mapping 
        @store_mapping ||= Stormpath::Rails::Client.client.account_store_mappings.create(
          application: Stormpath::Rails::Client.application,
          account_store: create_test_directory,
          is_default_account_store: true,
          is_default_group_store: true
        )
      end
    end
  end
end
