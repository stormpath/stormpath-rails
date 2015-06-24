module Stormpath
  module Testing
    module Helpers
      def sign_in
        @controller.authenticate test_user
        test_user
      end

      def create_test_account
        @test_account ||= Stormpath::Rails::Client.create_stormpath_account(test_user)
      end

      def delete_test_account
        @test_account.delete if @test_account
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