module Stormpath
  module Rails
    module UserConfig
      class ForgotPassword
        include Virtus.model

        attribute :enabled, Boolean, default: false
        attribute :uri, String
        attribute :view, String
        attribute :nextUri, String
      end
    end
  end
end