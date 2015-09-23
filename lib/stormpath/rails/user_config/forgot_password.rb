module Stormpath
  module Rails
    module UserConfig
      class ForgotPassword
        include Virtus.model

        attribute :enabled, Boolean, default: false
        attribute :uri, String, default: '/forgot'
      end
    end
  end
end
