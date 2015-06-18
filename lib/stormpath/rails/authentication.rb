module Stormpath
  module Rails
    module Authentication
      def create_stormpath_account(user)
        Stormpath::Rails::Client.create_stormpath_account(user)
      end
    end
  end
end