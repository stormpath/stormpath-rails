module Stormpath
  module Rails
    class LoginNewSerializer < FormSerializer
      private

      def config
        Stormpath::Rails.config.web.login
      end
    end
  end
end
