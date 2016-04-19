module Stormpath
  module Rails
    module UserConfig
      class Logout
        include Virtus.model

        attribute :enabled, Boolean, default: true
        attribute :uri, String, default: '/logout'
        attribute :next_uri, String, default: '/'
      end
    end
  end
end
