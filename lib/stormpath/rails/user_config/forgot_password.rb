module Stormpath
  module Rails
    module UserConfig
      class ForgotPassword
        include Virtus.model

        attribute :enabled, Boolean, default: false
        attribute :uri, String
        attribute :view, String
        attribute :next_uri, String
      end
    end
  end
end
