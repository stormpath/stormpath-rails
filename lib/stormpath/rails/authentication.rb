module Stormpath
  module Rails
    module Authentication
      def create_stormpath_account(user)
        Stormpath::Rails::Client.create_stormpath_account(user)
      end

      def authenticate(user)
        Stormpath::Rails::Client.authenticate(user)
      end

      def find_user(email)
        Stormpath::Rails.config.user_model.find_user email
      end
    end
  end
end