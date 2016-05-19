module Stormpath
  module Rails
    class RegistrationFormSerializer < FormSerializer
      private

      def config
        Stormpath::Rails.config.web.register
      end
    end
  end
end
