module Stormpath
  module Rails
    module UserConfig
      class VerifyEmail
        include Virtus.model

        attribute :enabled, Boolean, default: false
        attribute :uri, String
        attribute :next_uri, String
        attribute :view, String
      end
    end
  end
end
