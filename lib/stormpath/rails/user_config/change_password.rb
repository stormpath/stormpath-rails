module Stormpath
  module Rails
    module UserConfig
      class ChangePassword
        include Virtus.model

        attribute :enabled, Boolean, default: true
        attribute :auto_login, Boolean, default: false
        attribute :uri, String, default: '/change'
        attribute :next_uri, String, default: '/login?status=reset'
        attribute :error_uri, String, default: '/forgot?status=invalid_sptoken'
      end
    end
  end
end
