module Stormpath
  module Rails
    module UserConfig
      class ForgotPassword
        include Virtus.model

        alias_method :enabled?, :enabled

        attribute :enabled, Boolean, default: false
        attribute :uri, String
        attribute :view, String
        attribute :next_uri, String
      end
    end
  end
end
