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
        @test_account_result ||= begin
          result = Stormpath::Rails::Client.create_stormpath_account(test_user)
          raise result.error_message unless result.success?
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

      def test_user
        factory = Stormpath::Rails.config.user_model.to_s.underscore.to_sym
        @test_user ||= FactoryGirl.create(factory)
        @test_user.attributes = @test_user.attributes.merge!("password" => @test_user.password)
        @test_user
      end
    end
  end
end
