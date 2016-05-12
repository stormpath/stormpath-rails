module Stormpath
  module Rails
    module UserConfig
      class ForgotPassword
        include Virtus.model

        attribute :enabled, Boolean, default: nil
        # -> { Stormpath::Rails::Client.application.default_account_store_mapping.account_store. }
        attribute :uri, String, default: '/forgot'
        attribute :next_uri, String, default: '/login?status=forgot'
      end
    end
  end
end
