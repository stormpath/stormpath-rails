module Stormpath
  module Rails
    module UserConfig
      class IdSite
        include Virtus.model

        attribute :enabled, Boolean, default: false
        attribute :uri, String, default: '/redirect'
        attribute :next_uri, String, default: '/'
      end
    end
  end
end
