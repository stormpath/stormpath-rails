module Stormpath
  module Rails
    module UserConfig
      class IdSite
        include Virtus.model

        alias_method :enabled?, :enabled

        attribute :enabled, Boolean, default: false
        attribute :uri, String
        attribute :login_uri, String
        attribute :forgot_uri, String
        attribute :register_uri, String
      end
    end
  end
end
