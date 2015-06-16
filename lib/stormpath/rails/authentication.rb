module Stormpath
  module Rails
    module Authentication
      def sign_in(user)
        client = Stormpath::Rails::Client.sign_in(user)
      end
    end
  end
end